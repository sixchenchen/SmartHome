package com.womi.webmodule.config;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.womi.businessmodule.mapper.device.DeviceBindingMapper;
import com.womi.businessmodule.model.device.DeviceBinding;
import com.womi.commonmodule.constants.RedisConstants;
import com.womi.commonmodule.enums.BindStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class RedisCacheInitializer implements ApplicationRunner {

    private final DeviceBindingMapper bindingMapper;
    private final StringRedisTemplate redisTemplate;

    @Override
    public void run(ApplicationArguments args) {
        log.info("开始执行已绑定设备缓存差量同步...");
        long startTime = System.currentTimeMillis();

        // 1. 查出数据库当前所有有效绑定的 MAC
        List<DeviceBinding> activeBindings = bindingMapper.selectList(
                new LambdaQueryWrapper<DeviceBinding>()
                        .eq(DeviceBinding::getBindStatus, BindStatus.BOUND.getCode())
        );
        Set<String> dbMacs = activeBindings.stream()
                .map(DeviceBinding::getDeviceId)
                .collect(Collectors.toSet());

        // 2. 查出 Redis 当前存在的 MAC（如果 key 不存在，返回空集合）
        Set<String> redisMacs = redisTemplate.opsForSet().members(RedisConstants.BOUND_DEVICES_KEY);
        if (redisMacs == null) {
            redisMacs = new HashSet<>();
        }

        // 3. 计算差集：需要新增的
        Set<String> toAdd = new HashSet<>(dbMacs);
        toAdd.removeAll(redisMacs); // toAdd = dbMacs - redisMacs

        // 4. 计算差集：需要删除的
        Set<String> toRemove = new HashSet<>(redisMacs);
        toRemove.removeAll(dbMacs); // toRemove = redisMacs - dbMacs

        // 5. 执行增量更新，绝不 delete 整个 Key
        if (!toAdd.isEmpty()) {
            redisTemplate.opsForSet().add(RedisConstants.BOUND_DEVICES_KEY, toAdd.toArray(new String[0]));
        }
        if (!toRemove.isEmpty()) {
            redisTemplate.opsForSet().remove(RedisConstants.BOUND_DEVICES_KEY, toRemove.toArray());
        }

        log.info("缓存差量同步完成 - 耗时: {}ms, DB总数: {}, 新增: {}, 移除: {}",
                (System.currentTimeMillis() - startTime), dbMacs.size(), toAdd.size(), toRemove.size());
    }
}