package com.womi.webmodule.dto.ota.response;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class OtaStartResponse {

    private int total;
    private int success;
    private int failed;
    private List<String> failedDevices = new ArrayList<>();
    private List<String> commandIds = new ArrayList<>();
}