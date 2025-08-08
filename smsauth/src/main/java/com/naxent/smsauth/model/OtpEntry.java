package com.naxent.smsauth.model;

public class OtpEntry {
	private String otp;
	private long timestamp;

	public OtpEntry(String otp, long timestamp) {
		this.otp = otp;
		this.timestamp = timestamp;
	}

	public String getOtp() {
		return otp;
	}

	public long getTimestamp() {
		return timestamp;
	}
}
