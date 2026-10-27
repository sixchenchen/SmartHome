package com.womi.webmodule.config;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.womi.businessmodule.mapper.device.DeviceBindingMapper;
import com.womi.businessmodule.model.device.DeviceBinding;
import com.womi.commonmodule.constants.RedisConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class RedisCacheInitializer implements ApplicationRunner {

    private final DeviceBindingMapper bindingMapper;
    private final StringRedisTemplate redisTemplate;

    @Override
    public void run(ApplicationArguments args) {
        log.info("开始预热已绑定设备缓存...");

        // 1. 先清空旧的缓存（防止残留脏数据）
        redisTemplate.delete(RedisConstants.BOUND_DEVICES_KEY);

        // 2. 从数据库查出所有有效绑定的 MAC
        List<DeviceBinding> activeBindings = bindingMapper.selectList(
                new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getBindStatus, 1)
        );

        if (!activeBindings.isEmpty()) {
            String[] macArray = activeBindings.stream()
                    .map(DeviceBinding::getDeviceId)
                    .toArray(String[]::new);

            // 3. 批量塞入 Redis Set 中
            redisTemplate.opsForSet().add(RedisConstants.BOUND_DEVICES_KEY, macArray);
            log.info("缓存预热完成，共加载 {} 台已绑定设备", macArray.length);
        } else {
            log.info("缓存预热完成，当前无已绑定设备");
        }
    }
}