package com.thechain.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

import java.util.Properties;

/**
 * Email configuration for The Chain
 * Supports Gmail SMTP for development and production email providers
 */
@Configuration
public class EmailConfig {

    @Value("${spring.mail.host:smtp.gmail.com}")
    private String mailHost;

    @Value("${spring.mail.port:587}")
    private Integer mailPort;

    @Value("${spring.mail.username:}")
    private String mailUsername;

    @Value("${spring.mail.password:}")
    private String mailPassword;

    @Value("${spring.mail.protocol:smtp}")
    private String mailProtocol;

    @Value("${spring.mail.properties.mail.smtp.auth:true}")
    private String mailSmtpAuth;

    @Value("${spring.mail.properties.mail.smtp.starttls.enable:true}")
    private String mailSmtpStartTls;

    @Value("${spring.mail.properties.mail.smtp.starttls.required:true}")
    private String mailSmtpStartTlsRequired;

    @Value("${spring.mail.properties.mail.smtp.timeout:5000}")
    private String mailSmtpTimeout;

    @Value("${spring.mail.properties.mail.smtp.connectiontimeout:5000}")
    private String mailSmtpConnectionTimeout;

    @Bean
    public JavaMailSender javaMailSender() {
        JavaMailSenderImpl mailSender = new JavaMailSenderImpl();

        mailSender.setHost(mailHost);
        mailSender.setPort(mailPort);
        mailSender.setUsername(mailUsername);
        mailSender.setPassword(mailPassword);
        mailSender.setProtocol(mailProtocol);

        Properties props = mailSender.getJavaMailProperties();
        props.put("mail.smtp.auth", mailSmtpAuth);
        props.put("mail.smtp.starttls.enable", mailSmtpStartTls);
        props.put("mail.smtp.starttls.required", mailSmtpStartTlsRequired);
        props.put("mail.smtp.timeout", mailSmtpTimeout);
        props.put("mail.smtp.connectiontimeout", mailSmtpConnectionTimeout);

        // Additional properties for reliability
        props.put("mail.debug", "false");
        props.put("mail.transport.protocol", mailProtocol);

        return mailSender;
    }
}
