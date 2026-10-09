package com.womi.businessmodule.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.womi.businessmodule.mapper.FirmwareMapper;
import com.womi.businessmodule.model.Firmware;
import com.womi.businessmodule.service.FirmwareService;
import com.womi.commonmodule.constants.ErrorInfoConstants;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
public class FirmwareServiceImpl extends ServiceImpl<FirmwareMapper, Firmware> implements FirmwareService {

    @Override
    public Firmware getByVersion(String version, String product) {
        return baseMapper.selectByVersionAndProduct(version, product);
    }

    @Override
    public List<Firmware> listEnabled() {
        return baseMapper.selectAllEnabled();
    }

    @Override
    public Firmware getLatestByProduct(String product) {
        return baseMapper.selectLatestByProduct(product);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Firmware saveFirmware(Firmware firmware) {
        // 检查版本是否已存在
        Firmware exist = getByVersion(firmware.getVersion(), firmware.getProduct());
        if (exist != null) {
            throw new BusinessException(ErrorCode.FIRMWARE_EXIST, ErrorInfoConstants.FIRMWARE_EXIST);
        }
        save(firmware);
        log.info("固件入库 - version: {}, md5: {}, size: {}", firmware.getVersion(), firmware.getMd5(), firmware.getSize());
        return firmware;
    }
}