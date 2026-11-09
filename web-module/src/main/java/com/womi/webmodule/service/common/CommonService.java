package com.womi.webmodule.service.common;

import com.womi.businessmodule.vo.AvatarUploadResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * 通用能力服务（字典、文件上传）
 */
public interface CommonService {

    AvatarUploadResponse uploadAvatar(MultipartFile file);

    /**
     * 删除用户旧头像文件（仅接受本服务上传目录下的 URL，非法地址直接忽略）
     */
    void deleteAvatarFile(String avatarUrl);

    Map<String, Object> getDictionaries();
}
