package util;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;

public class S3FileStorage {
    private static final String DEFAULT_BUCKET = "projectos-files-234073094853-apne2";
    private static final String DEFAULT_REGION = "ap-northeast-2";

    private final String bucket;
    private final String region;

    public S3FileStorage() {
        this.bucket = readSetting("PROJECTOS_S3_BUCKET", DEFAULT_BUCKET);
        this.region = readSetting("AWS_REGION", DEFAULT_REGION);
    }

    public String getBucket() {
        return bucket;
    }

    public void upload(InputStream input, String key, String contentType) throws IOException, InterruptedException {
        Path tempFile = Files.createTempFile("projectos-upload-", ".tmp");
        try {
            Files.copy(input, tempFile, StandardCopyOption.REPLACE_EXISTING);
            if (contentType == null || contentType.trim().isEmpty()) {
                run(List.of("aws", "s3", "cp", tempFile.toString(), uri(key), "--region", region));
            } else {
                run(List.of("aws", "s3", "cp", tempFile.toString(), uri(key), "--region", region, "--content-type", contentType));
            }
        } finally {
            Files.deleteIfExists(tempFile);
        }
    }

    public void download(String key, OutputStream output) throws IOException, InterruptedException {
        Path tempFile = Files.createTempFile("projectos-download-", ".tmp");
        try {
            run(List.of("aws", "s3", "cp", uri(key), tempFile.toString(), "--region", region));
            Files.copy(tempFile, output);
        } finally {
            Files.deleteIfExists(tempFile);
        }
    }

    public void delete(String key) throws IOException, InterruptedException {
        run(List.of("aws", "s3", "rm", uri(key), "--region", region));
    }

    private String uri(String key) {
        return "s3://" + bucket + "/" + key;
    }

    private void run(List<String> command) throws IOException, InterruptedException {
        Process process = new ProcessBuilder(command).redirectErrorStream(true).start();
        String output;
        try (InputStream stream = process.getInputStream()) {
            output = new String(stream.readAllBytes(), StandardCharsets.UTF_8);
        }
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new IOException("AWS CLI failed (" + exitCode + "): " + output);
        }
    }

    private static String readSetting(String key, String fallback) {
        String value = System.getenv(key);
        if (value == null || value.trim().isEmpty()) {
            value = System.getProperty(key);
        }
        return (value == null || value.trim().isEmpty()) ? fallback : value.trim();
    }
}
