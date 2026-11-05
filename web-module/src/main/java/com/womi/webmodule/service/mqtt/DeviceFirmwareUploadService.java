package com.womi.webmodule.service.mqtt;

import com.womi.businessmodule.vo.FirmwareUploadResponse;
import com.womi.businessmodule.vo.FirmwareVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface DeviceFirmwareUploadService {

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
     * 固件分页（管理端）
     */
    Page<FirmwareVO> pageFirmware(Integer pageNum, Integer pageSize, String product, Integer status, String keyword);

    /**
     * 固件详情
     */
    FirmwareVO getDetail(Long id);

    /**
     * 启用/禁用固件
     */
    void updateStatus(Long id, Integer status);

    /**
     * 删除固件
     */
    void delete(Long id);
}