package com.naxent.smsauth.controller;

import com.naxent.smsauth.dto.SendOtpRequest;
import com.naxent.smsauth.dto.VerifyOtpRequest;
import com.naxent.smsauth.service.OtpService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/otp")
public class OtpController {

	@Autowired
	private OtpService otpService;

	@PostMapping("/send")
	public String sendOtp(@RequestBody SendOtpRequest request) {
		try {
			return otpService.sendOtp(request.getMobile());
		} catch (Exception e) {
			return "Failed to send OTP: " + e.getMessage();
		}
	}

	@PostMapping("/verify")
	public String verifyOtp(@RequestBody VerifyOtpRequest request) {
		return otpService.verifyOtp(request.getMobile(), request.getOtp());
	}
}
