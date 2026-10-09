package com.womi.webmodule.service.impl;

import com.womi.businessmodule.model.Firmware;
import com.womi.businessmodule.service.FirmwareService;
import com.womi.commonmodule.constants.CommandConstants;
import com.womi.commonmodule.constants.ErrorInfoConstants;
import com.womi.commonmodule.constants.FileConstants;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.commonmodule.utils.DateTimeUtils;
import com.womi.webmodule.dto.firmware.response.FirmwareUploadResponse;
import com.womi.webmodule.dto.firmware.response.FirmwareVO;
import com.womi.webmodule.service.FirmwareUploadService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.DigestUtils;
import org.springframework.util.unit.DataSize;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

import static com.womi.commonmodule.enums.ErrorCode.FILE_UPLOAD_FAILED;

@Slf4j
@Service
@RequiredArgsConstructor
public class FirmwareUploadServiceImpl implements FirmwareUploadService {

    private final FirmwareService firmwareService;

    @Value("${firmware.upload-dir:D:/data/firmware/}")
    private String uploadDir;

    @Value("${firmware.base-url:http://192.168.1.15:8000/firmware/}")
    private String baseUrl;

    @Value("${firmware.file-name-pattern:firmware_%s_%s.bin}")
    private String fileNamePattern;

    @Value("${firmware.max-size:16MB}")
    private DataSize maxFirmwareSize;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public FirmwareUploadResponse upload(MultipartFile file, String version,
                                         String product, String releaseNotes,
                                         String operator) {
        // ==================== 1. 基础校验 ====================
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ErrorCode.FILE_EMPTY);
        }
        if (file.getSize() > maxFirmwareSize.toBytes()) {
            throw new BusinessException(ErrorCode.FILE_TOO_LARGE, ErrorInfoConstants.FIRMWARE_FILE_TOO_LARGE);
        }
        if (version == null || version.isBlank()) {
            throw new BusinessException(ErrorCode.PARAM_MISSING, ErrorInfoConstants.VERSION_EMPTY);
        }
        if (!file.getOriginalFilename().endsWith(FileConstants.FIRMWARE_EXTENSION)) {
            throw new BusinessException(ErrorCode.FILE_FORMAT_ERROR, ErrorInfoConstants.FILE_FORMAT_MUST_BIN);
        }

        // 版本已存在直接拒绝
        Firmware exist = firmwareService.getByVersion(version, product);
        if (exist != null) {
            throw new BusinessException(ErrorCode.FIRMWARE_EXIST, ErrorInfoConstants.FIRMWARE_EXIST);
        }

        // ==================== 2. 写文件 ====================
        Path targetPath = null;
        try {
            String timestamp = DateTimeUtils.nowCompact();
            String fileName = String.format(fileNamePattern, version, timestamp);

            Path dirPath = Paths.get(uploadDir);
            Files.createDirectories(dirPath);
            targetPath = dirPath.resolve(fileName);

            // 流式写入 + 算 MD5
            String md5 = computeAndSave(file, targetPath);
            String sha256 = computeSha256(targetPath);
            String url = baseUrl + fileName;

            // ==================== 3. 入库 ====================
            Firmware firmware = new Firmware();
            firmware.setVersion(version);
            firmware.setProduct(product);
            firmware.setReleaseNotes(releaseNotes);
            firmware.setUrl(url);
            firmware.setFileName(file.getOriginalFilename());
            firmware.setFilePath(targetPath.toString());
            firmware.setMd5(md5);
            firmware.setSha256(sha256);
            firmware.setSize(file.getSize());
            firmware.setUploadedBy(operator != null ? operator : CommandConstants.DEFAULT_OPERATOR);
            firmware.setUploadTime(LocalDateTime.now());
            firmware.setStatus(1);

            firmware = firmwareService.saveFirmware(firmware);

            log.info("固件上传成功 - id: {}, version: {}, md5: {}, size: {}", firmware.getId(), version, md5, file.getSize());

            // ==================== 4. 组装响应 ====================
            FirmwareUploadResponse response = new FirmwareUploadResponse();
            response.setId(firmware.getId());
            response.setVersion(version);
            response.setProduct(product);
            response.setUrl(url);
            response.setMd5(md5);
            response.setSha256(sha256);
            response.setSize(file.getSize());
            return response;

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
        Firmware firmware = firmwareService.getById(id);
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

            byte[] buffer = new byte[FileConstants.UPLOAD_BUFFER_SIZE];
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
            byte[] buffer = new byte[FileConstants.UPLOAD_BUFFER_SIZE];
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

    private FirmwareVO toVO(Firmware firmware) {
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