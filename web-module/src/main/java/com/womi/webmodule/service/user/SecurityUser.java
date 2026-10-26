package com.womi.webmodule.service.user;

import com.womi.businessmodule.model.sys.SysUser;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;

@Getter
public class SecurityUser implements UserDetails {

    private final SysUser sysUser;
    private final Collection<? extends GrantedAuthority> authorities;

    // 修复：使用 Collection<? extends GrantedAuthority>，这样传入 List<SimpleGrantedAuthority> 就不会报错了
    public SecurityUser(SysUser sysInfo, Collection<? extends GrantedAuthority> authorities) {
        this.sysUser = sysInfo;
        this.authorities = authorities;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return sysUser.getPasswordHash();
    }

    @Override
    public String getUsername() {
        return sysUser.getUsername();
    }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() {
        return sysUser.getStatus() != null && sysUser.getStatus() == 1;
    }
}