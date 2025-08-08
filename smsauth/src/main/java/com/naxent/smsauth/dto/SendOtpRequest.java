package com.naxent.smsauth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class SendOtpRequest {

	@NotBlank(message = "Mobile number is required")
	@Pattern(regexp = "^(91\\d{10}|[6-9]\\d{9})(,(91\\d{10}|[6-9]\\d{9}))*$", message = "Enter valid mobile numbers (10 or 12 digits, comma-separated)")
	private String mobile;

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}
}
