package com.womi.commonmodule.constants;

/**
 * CSV 导出常量
 */
public final class CsvConstants {

    private CsvConstants() {
    }

    /** CSV 响应类型 */
    public static final String CONTENT_TYPE = "text/csv;charset=UTF-8";

    /** 响应头 */
    public static final String HEADER_CONTENT_DISPOSITION = "Content-Disposition";

    /** 附件下载格式 */
    public static final String DISPOSITION_FORMAT = "attachment;filename=%s";

    /** UTF-8 BOM，防止 Excel 打开中文乱码 */
    public static final char UTF8_BOM = '\uFEFF';

    // ==================== 设备导出 ====================

    public static final String DEVICE_FILE_NAME = "devices.csv";

    public static final String DEVICE_HEADER =
            "ID,设备MAC,设备名称,产品,固件版本,位置,绑定码,在线状态,最后在线时间,最后心跳时间,创建时间";

    public static final String DELIMITER = ",";

    /** 字段引用符 */
    public static final String QUOTE = "\"";

    /** 引用符转义（CSV 规范：双写） */
    public static final String ESCAPED_QUOTE = "\"\"";

    /** 字段内的换行符 */
    public static final String NEW_LINE = "\n";
}
