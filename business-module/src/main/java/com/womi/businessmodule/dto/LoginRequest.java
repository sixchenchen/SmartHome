package com.womi.businessmodule.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String username;
    private String password;
}
