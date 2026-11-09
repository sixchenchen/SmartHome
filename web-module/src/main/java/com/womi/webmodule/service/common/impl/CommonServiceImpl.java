package com.womi.webmodule.service.common.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.womi.businessmodule.mapper.device.DeviceInfoMapper;
import com.womi.businessmodule.mapper.sys.SysRoleMapper;
import com.womi.businessmodule.model.device.DeviceInfo;
import com.womi.businessmodule.vo.AvatarUploadResponse;
import com.womi.commonmodule.constants.AvatarConstants;
import com.womi.commonmodule.constants.DictionaryConstants;
import com.womi.commonmodule.constants.DeviceOtaStateConstants;
import com.womi.commonmodule.enums.AlertStatus;
import com.womi.commonmodule.enums.DeviceCommandStatus;
import com.womi.commonmodule.enums.DeviceOnlineStatus;
import com.womi.commonmodule.enums.EnableStatus;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import com.womi.webmodule.service.common.CommonService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CommonServiceImpl implements CommonService {

    private final SysRoleMapper sysRoleMapper;
    private final DeviceInfoMapper deviceInfoMapper;

    @Value("${app.upload.avatar-dir:" + AvatarConstants.DEFAULT_DIR + "}")
    private String avatarDir;

    @Value("${app.upload.avatar-base-url:" + AvatarConstants.DEFAULT_BASE_URL + "}")
    private String avatarBaseUrl;

    @Override
    public AvatarUploadResponse uploadAvatar(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ErrorCode.FILE_EMPTY);
        }
        if (file.getSize() > AvatarConstants.MAX_SIZE) {
            throw new BusinessException(ErrorCode.FILE_TOO_LARGE, AvatarConstants.MSG_SIZE_EXCEEDED);
        }
        String contentType = file.getContentType();
        String extension = switch (contentType == null ? "" : contentType) {
            case AvatarConstants.CONTENT_TYPE_JPEG -> AvatarConstants.EXTENSION_JPG;
            case AvatarConstants.CONTENT_TYPE_PNG -> AvatarConstants.EXTENSION_PNG;
            case AvatarConstants.CONTENT_TYPE_WEBP -> AvatarConstants.EXTENSION_WEBP;
            default -> throw new BusinessException(ErrorCode.FILE_FORMAT_ERROR, AvatarConstants.MSG_FORMAT_UNSUPPORTED);
        };

        String filename = UUID.randomUUID().toString().replace(AvatarConstants.UUID_SEPARATOR, "")
                + AvatarConstants.EXTENSION_SEPARATOR + extension;
        try {
            Path dir = Paths.get(avatarDir).toAbsolutePath().normalize();
            Files.createDirectories(dir);
            Path target = dir.resolve(filename);
            file.transferTo(target.toFile());

            AvatarUploadResponse response = new AvatarUploadResponse();
            response.setUrl(avatarBaseUrl + filename);
            response.setSize(file.getSize());
            response.setContentType(contentType);
            return response;
        } catch (IOException e) {
            log.error("头像保存失败", e);
            throw new BusinessException(ErrorCode.FILE_UPLOAD_FAILED);
        }
    }

    @Override
    public void deleteAvatarFile(String avatarUrl) {
        if (avatarUrl == null || !avatarUrl.startsWith(avatarBaseUrl)) {
            return;
        }
        String filename = avatarUrl.substring(avatarBaseUrl.length());
        if (!filename.matches(AvatarConstants.FILE_NAME_REGEX)) {
            log.warn("忽略非法的头像删除请求: {}", avatarUrl);
            return;
        }
        try {
            Path dir = Paths.get(avatarDir).toAbsolutePath().normalize();
            Files.deleteIfExists(dir.resolve(filename));
        } catch (IOException e) {
            log.warn("旧头像文件删除失败: {}", avatarUrl, e);
        }
    }

    @Override
    public Map<String, Object> getDictionaries() {
        Map<String, Object> result = new LinkedHashMap<>();

        List<Map<String, Object>> roles = sysRoleMapper.selectList(new LambdaQueryWrapper<>()).stream()
                .map(role -> Map.<String, Object>of(DictionaryConstants.FIELD_CODE, role.getRoleCode(),
                        DictionaryConstants.FIELD_NAME, role.getRoleName()))
                .collect(Collectors.toList());
        result.put(DictionaryConstants.KEY_ROLES, roles);

        result.put(DictionaryConstants.KEY_USER_STATUS, Arrays.asList(
                item(EnableStatus.ENABLED.getCode(), EnableStatus.ENABLED.getMessage()),
                item(EnableStatus.DISABLED.getCode(), EnableStatus.DISABLED.getMessage())));

        result.put(DictionaryConstants.KEY_DEVICE_ONLINE, Arrays.asList(
                item(DeviceOnlineStatus.ONLINE.getCode(), DeviceOnlineStatus.ONLINE.getMessage()),
                item(DeviceOnlineStatus.OFFLINE.getCode(), DeviceOnlineStatus.OFFLINE.getMessage())));

        List<Map<String, Object>> commandStatus = new ArrayList<>();
        for (DeviceCommandStatus status : DeviceCommandStatus.values()) {
            commandStatus.add(item(status.getCode(), status.getMessage()));
        }
        result.put(DictionaryConstants.KEY_COMMAND_STATUS, commandStatus);

        result.put(DictionaryConstants.KEY_OTA_STATE, DeviceOtaStateConstants.STATE_LABELS.stream()
                .map(entry -> item(entry.getKey(), entry.getValue()))
                .collect(Collectors.toList()));

        result.put(DictionaryConstants.KEY_ALERT_LEVEL, DictionaryConstants.ALERT_LEVELS.stream()
                .map(entry -> item(entry.getKey(), entry.getValue()))
                .collect(Collectors.toList()));

        List<Map<String, Object>> alertStatus = new ArrayList<>();
        for (AlertStatus status : AlertStatus.values()) {
            alertStatus.add(item(status.getCode(), status.getMessage()));
        }
        result.put(DictionaryConstants.KEY_ALERT_STATUS, alertStatus);

        List<Object> products = deviceInfoMapper.selectObjs(new QueryWrapper<DeviceInfo>()
                .select("DISTINCT product")
                .isNotNull("product"));
        result.put(DictionaryConstants.KEY_PRODUCTS, products);
        return result;
    }

    private Map<String, Object> item(Object value, String label) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put(DictionaryConstants.FIELD_VALUE, value);
        map.put(DictionaryConstants.FIELD_LABEL, label);
        return map;
    }
}
