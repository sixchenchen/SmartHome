package com.womi.webmodule.service;

import com.womi.webmodule.dto.firmware.response.FirmwareUploadResponse;
import com.womi.webmodule.dto.firmware.response.FirmwareVO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface FirmwareUploadService {

    /**
     * 上传固件
     */
    FirmwareUploadResponse upload(MultipartFile file, String version,
                                  String product, String releaseNotes,
                                  String operator);

    /**
     * 查询所有固件
     */
    List<FirmwareVO> listAll();

    /**
     * 删除固件
     */
    void delete(Long id);
}