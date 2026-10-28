package com.womi.webmodule.service.mqtt.impl;

import com.womi.businessmodule.model.device.DeviceFirmware;
import com.womi.businessmodule.service.device.DeviceFirmwareService;
import com.womi.commonmodule.constants.DeviceCommandConstants;
import com.womi.commonmodule.constants.ErrorInfoConstants;
import com.womi.commonmodule.constants.FirmwareConstants;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.properties.FirmwareProperties;
import com.womi.commonmodule.utils.DateTimeUtils;
import com.womi.businessmodule.vo.FirmwareUploadResponse;
import com.womi.businessmodule.vo.FirmwareVO;
import com.womi.webmodule.service.mqtt.DeviceFirmwareUploadService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import static com.womi.commonmodule.enums.ErrorCode.FILE_UPLOAD_FAILED;

@Slf4j
@Service
@RequiredArgsConstructor
public class DeviceFirmwareUploadServiceImpl implements DeviceFirmwareUploadService {

    private final DeviceFirmwareService firmwareService;

    private final FirmwareProperties firmwareProperties;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public FirmwareUploadResponse upload(MultipartFile file, String version,
                                         String product, String releaseNotes,
                                         String operator) {
        // ==================== 1. 基础校验 ====================
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ErrorCode.FILE_EMPTY);
        }
        if (file.getSize() > firmwareProperties.getMaxSize().toBytes()) {
            throw new BusinessException(ErrorCode.FILE_TOO_LARGE, ErrorInfoConstants.FIRMWARE_FILE_TOO_LARGE);
        }
        if (version == null || version.isBlank()) {
            throw new BusinessException(ErrorCode.PARAM_MISSING, ErrorInfoConstants.VERSION_EMPTY);
        }
        if (!Objects.requireNonNull(file.getOriginalFilename()).endsWith(FirmwareConstants.FIRMWARE_EXTENSION)) {
            throw new BusinessException(ErrorCode.FILE_FORMAT_ERROR, ErrorInfoConstants.FILE_FORMAT_MUST_BIN);
        }

        if (!version.matches("^[0-9A-Za-z._-]+$")) {
            log.warn("固件上传拦截：非法的版本号格式 - version: {}", version);
            throw new BusinessException(ErrorCode.PARAM_ERROR, "版本号格式错误，只能包含字母、数字、下划线和点");
        }

        // 版本已存在直接拒绝
        DeviceFirmware exist = firmwareService.getByVersion(version, product);
        if (exist != null) {
            throw new BusinessException(ErrorCode.FIRMWARE_EXIST, ErrorInfoConstants.FIRMWARE_EXIST);
        }

        // ==================== 2. 写文件 ====================
        Path targetPath = null;
        try {
            String timestamp = DateTimeUtils.nowCompact();
            String fileName = String.format(firmwareProperties.getFileNamePattern(), version, timestamp);
            Path dirPath = Paths.get(firmwareProperties.getUploadDir()).toAbsolutePath().normalize();
            Files.createDirectories(dirPath);
            targetPath = dirPath.resolve(fileName);
            if (!targetPath.startsWith(dirPath)) {
                log.error("固件上传安全拦截：检测到路径穿越攻击！ - 期望目录: {}, 实际路径: {}", dirPath, targetPath);
                throw new BusinessException(ErrorCode.PARAM_ERROR, "非法的文件路径");
            }
            // 流式写入 + 算 MD5
            String md5 = computeAndSave(file, targetPath);
            String sha256 = computeSha256(targetPath);
            String url = firmwareProperties.getBaseUrl() + fileName;

            // ==================== 3. 入库 ====================
            DeviceFirmware firmware = DeviceFirmware.builder()
                    .version(version)
                    .product(product)
                    .releaseNotes(releaseNotes)
                    .url(url)
                    .fileName(file.getOriginalFilename())
                    .filePath(targetPath.toString())
                    .md5(md5)
                    .sha256(sha256)
                    .size(file.getSize())
                    .uploadedBy(StringUtils.hasText(operator) ? operator : DeviceCommandConstants.DEFAULT_OPERATOR)
                    .uploadTime(LocalDateTime.now())
                    .status(1)
                    .build();

            firmware = firmwareService.saveFirmware(firmware);

            log.info("固件上传成功 - id: {}, version: {}, md5: {}, size: {}", firmware.getId(), version, md5, file.getSize());

            // ==================== 4. 组装响应 ====================
            return FirmwareUploadResponse.builder()
                    .id(firmware.getId())
                    .version(version)
                    .product(product)
                    .url(url)
                    .md5(md5)
                    .sha256(sha256)
                    .size(file.getSize())
                    .build();

        } catch (Exception e) {
            // 入库失败时清理已写入的文件
            if (targetPath != null) {
                try {
                    Files.deleteIfExists(targetPath);
                    log.info("清理失败上传的固件文件 - path: {}", targetPath);
                } catch (Exception ex) {
                    log.warn("清理固件文件失败 - path: {}", targetPath, ex);
                }
            }
            log.error("固件上传失败 - version: {}", version, e);
            throw new BusinessException(FILE_UPLOAD_FAILED,ErrorInfoConstants.FIRMWARE_UPLOAD_FAILED);
        }
    }

    @Override
    public List<FirmwareVO> listAll() {
        return firmwareService.listEnabled().stream()
                .map(this::toVO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        DeviceFirmware firmware = firmwareService.getById(id);
        if (firmware == null) {
            throw new BusinessException(ErrorCode.FIRMWARE_NOT_FOUND,ErrorInfoConstants.FIRMWARE_FILE_NOT_FOUND);
        }

        // 删除磁盘文件
        if (firmware.getFilePath() != null) {
            try {
                Files.deleteIfExists(Paths.get(firmware.getFilePath()));
            } catch (Exception e) {
                log.warn("删除固件文件失败 - path: {}", firmware.getFilePath(), e);
            }
        }

        firmwareService.removeById(id);
        log.info("固件删除成功 - id: {}", id);
    }

    // ==================== 私有方法 ====================

    /**
     * 流式读取，同时算 MD5 并写入磁盘
     */
    private String computeAndSave(MultipartFile file, Path targetPath) throws Exception {
        MessageDigest md5Digest = MessageDigest.getInstance("MD5");

        try (InputStream in = file.getInputStream();
             OutputStream out = Files.newOutputStream(targetPath)) {

            byte[] buffer = new byte[FirmwareConstants.UPLOAD_BUFFER_SIZE];
            int n;
            while ((n = in.read(buffer)) > 0) {
                md5Digest.update(buffer, 0, n);
                out.write(buffer, 0, n);
            }
        }

        return bytesToHex(md5Digest.digest());
    }

    /**
     * 计算 SHA256
     */
    private String computeSha256(Path path) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        try (InputStream in = Files.newInputStream(path)) {
            byte[] buffer = new byte[FirmwareConstants.UPLOAD_BUFFER_SIZE];
            int n;
            while ((n = in.read(buffer)) > 0) {
                digest.update(buffer, 0, n);
            }
        }
        return bytesToHex(digest.digest());
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    private FirmwareVO toVO(DeviceFirmware firmware) {
        FirmwareVO vo = new FirmwareVO();
        vo.setId(firmware.getId());
        vo.setVersion(firmware.getVersion());
        vo.setProduct(firmware.getProduct());
        vo.setReleaseNotes(firmware.getReleaseNotes());
        vo.setUrl(firmware.getUrl());
        vo.setMd5(firmware.getMd5());
        vo.setSha256(firmware.getSha256());
        vo.setSize(firmware.getSize());
        vo.setSizeText(formatSize(firmware.getSize()));
        vo.setUploadedBy(firmware.getUploadedBy());
        vo.setUploadTime(firmware.getUploadTime());
        vo.setStatus(firmware.getStatus());
        return vo;
    }

    private String formatSize(Long size) {
        if (size == null) return "0 B";
        if (size < 1024) return size + " B";
        if (size < 1024 * 1024) return String.format("%.1f KB", size / 1024.0);
        return String.format("%.2f MB", size / 1024.0 / 1024.0);
    }
}