package com.womi.webmodule.security;

import lombok.Getter;
import java.security.Principal;

@Getter
public class StompPrincipal implements Principal {
    private final Long userId;
    private final String username;
    private final boolean isAdmin;

    public StompPrincipal(Long userId, String username, boolean isAdmin) {
        this.userId = userId;
        this.username = username;
        this.isAdmin = isAdmin;
    }

    @Override
    public String getName() {
        return username;
    }
}