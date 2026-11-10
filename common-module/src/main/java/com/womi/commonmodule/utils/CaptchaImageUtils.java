package com.womi.commonmodule.utils;

import com.womi.commonmodule.constants.CaptchaConstants;
import com.womi.commonmodule.enums.ErrorCode;
import com.womi.commonmodule.exception.BusinessException;

import javax.imageio.ImageIO;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

/**
 * 图片验证码渲染工具
 */
public final class CaptchaImageUtils {

    private CaptchaImageUtils() {
    }

    /**
     * 渲染图片验证码
     *
     * @param code       验证码文本
     * @param width      图片宽度
     * @param height     图片高度
     * @param noiseLines 干扰线数量
     * @return PNG 图片字节
     */
    public static byte[] render(String code, int width, int height, int noiseLines) {
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics = image.createGraphics();
        try {
            graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            graphics.setColor(new Color(CaptchaConstants.BACKGROUND_RGB));
            graphics.fillRect(0, 0, width, height);

            for (int i = 0; i < noiseLines; i++) {
                graphics.setColor(randomColor(CaptchaConstants.COLOR_LIGHT_MIN, CaptchaConstants.COLOR_LIGHT_MAX));
                graphics.drawLine(CaptchaUtils.nextInt(width), CaptchaUtils.nextInt(height),
                        CaptchaUtils.nextInt(width), CaptchaUtils.nextInt(height));
            }

            int fontSize = Math.max(CaptchaConstants.FONT_SIZE_MIN, height - CaptchaConstants.FONT_SIZE_HEIGHT_OFFSET);
            int charWidth = width / (code.length() + 1);
            for (int i = 0; i < code.length(); i++) {
                graphics.setFont(new Font(CaptchaConstants.FONT_NAME, Font.BOLD, fontSize));
                graphics.setColor(randomColor(CaptchaConstants.COLOR_DARK_MIN, CaptchaConstants.COLOR_DARK_MAX));

                int x = charWidth / 2 + i * charWidth + CaptchaUtils.nextInt(CaptchaConstants.CHAR_X_JITTER);
                int y = height / 2 + fontSize / 3
                        + CaptchaUtils.nextInt(CaptchaConstants.CHAR_Y_JITTER) - CaptchaConstants.CHAR_Y_JITTER / 2;
                double angle = (CaptchaUtils.nextDouble() - 0.5) * CaptchaConstants.MAX_ROTATION_DEGREE * 2;

                AffineTransform original = graphics.getTransform();
                graphics.rotate(Math.toRadians(angle), x, y);
                graphics.drawString(String.valueOf(code.charAt(i)), x, y);
                graphics.setTransform(original);
            }
        } finally {
            graphics.dispose();
        }

        try (ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            ImageIO.write(image, CaptchaConstants.IMAGE_FORMAT, output);
            return output.toByteArray();
        } catch (IOException e) {
            throw new BusinessException(ErrorCode.CAPTCHA_GENERATE_FAILED);
        }
    }

    private static Color randomColor(int min, int max) {
        int bound = Math.max(1, max - min);
        return new Color(min + CaptchaUtils.nextInt(bound),
                min + CaptchaUtils.nextInt(bound),
                min + CaptchaUtils.nextInt(bound));
    }
}
