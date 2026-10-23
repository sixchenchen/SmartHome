package com.womi.webmodule.service.user.impl;

import com.womi.businessmodule.model.sys.SysInfo;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;

@Getter
public class SecurityUser implements UserDetails {

    private final SysInfo sysInfo;
    private final Collection<? extends GrantedAuthority> authorities;

    // 修复：使用 Collection<? extends GrantedAuthority>，这样传入 List<SimpleGrantedAuthority> 就不会报错了
    public SecurityUser(SysInfo sysInfo, Collection<? extends GrantedAuthority> authorities) {
        this.sysInfo = sysInfo;
        this.authorities = authorities;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return sysInfo.getPasswordHash();
    }

    @Override
    public String getUsername() {
        return sysInfo.getUsername();
    }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() {
        return sysInfo.getStatus() != null && sysInfo.getStatus() == 1;
    }
}