package com.womi.webmodule.service.common;

import com.womi.businessmodule.vo.AvatarUploadResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * 通用能力服务（字典、文件上传）
 */
public interface CommonService {

    AvatarUploadResponse uploadAvatar(MultipartFile file);

    Map<String, Object> getDictionaries();
}
