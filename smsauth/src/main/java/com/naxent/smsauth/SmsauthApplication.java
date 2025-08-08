package com.naxent.smsauth;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class SmsauthApplication {

	public static void main(String[] args) {
		SpringApplication.run(SmsauthApplication.class, args);
	}

}
