package com.naxent.smsauth.service;

import com.naxent.smsauth.model.OtpEntry;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class OtpService {

	@Value("${sms.api.url}")
	private String smsApiUrl;

	@Value("${sms.api.key}")
	private String apiKey;

	@Value("${sms.sender.id}")
	private String senderId;

	@Value("${sms.support.number}")
	private String supportNumber;

	@Value("${sms.otp.template}")
	private String otpMessageTemplate;

	@Value("${sms.otp.validity.seconds}")
	private int otpValiditySeconds;

	@Value("${sms.otp.cleanup.seconds}")
	private int otpLifetimeSeconds;

	private final Map<String, OtpEntry> otpStorage = new ConcurrentHashMap<>();

	public String sendOtp(String mobileList) throws Exception {
		String[] numbers = mobileList.split(",");
		StringBuilder result = new StringBuilder();

		for (String mobile : numbers) {
			mobile = mobile.trim();
			String otp = String.valueOf(new Random().nextInt(900000) + 100000);
			long timestamp = System.currentTimeMillis();
			otpStorage.put(mobile, new OtpEntry(otp, timestamp));

			// Format message from template
			String message = otpMessageTemplate.replace("{OTP}", otp).replace("{SUPPORT}", supportNumber);

			URI uri = UriComponentsBuilder.fromHttpUrl(smsApiUrl).queryParam("apikey", apiKey)
					.queryParam("senderid", senderId).queryParam("number", mobile).queryParam("message", message)
					.build().encode().toUri();

			HttpRequest request = HttpRequest.newBuilder().uri(uri).GET().build();
			HttpResponse<String> response = HttpClient.newHttpClient().send(request,
					HttpResponse.BodyHandlers.ofString());

			result.append("Sent to ").append(mobile).append(": ").append(response.body()).append("\n");
		}

		return result.toString();
	}

	public String verifyOtp(String mobile, String otp) {
		OtpEntry entry = otpStorage.get(mobile);

		if (entry == null) {
			return "No OTP found for this number. Please request a new one.";
		}

		long currentTime = System.currentTimeMillis();
		long ageInSeconds = (currentTime - entry.getTimestamp()) / 1000;

		if (ageInSeconds > otpValiditySeconds) {
			otpStorage.remove(mobile);
			return "OTP expired. Please request a new one.";
		}

		if (entry.getOtp().equals(otp)) {
			otpStorage.remove(mobile);
			return "OTP Verified Successfully!";
		} else {
			return "Invalid OTP. Please try again.";
		}
	}

	@Scheduled(fixedRate = 60000)
	public void cleanExpiredOtps() {
		long now = System.currentTimeMillis();
		otpStorage.entrySet().removeIf(entry -> {
			long ageInSeconds = (now - entry.getValue().getTimestamp()) / 1000;
			return ageInSeconds > otpLifetimeSeconds;
		});
		System.out.println("[Scheduled Cleanup] OTPs older than " + otpLifetimeSeconds + " seconds removed.");
	}
}
