package storage

import (
	"context"
	"fmt"
	"io"
	"mime/multipart"
	"path/filepath"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/google/uuid"
)

// S3Storage はAWS S3を使用したファイルストレージの実装です
type S3Storage struct {
	client     *s3.Client
	bucketName string
	region     string
}

// NewS3Storage は新しいS3Storageを作成します
func NewS3Storage(client *s3.Client, bucketName, region string) *S3Storage {
	return &S3Storage{
		client:     client,
		bucketName: bucketName,
		region:     region,
	}
}

// Upload はファイルをS3にアップロードします
func (s *S3Storage) Upload(ctx context.Context, file *multipart.FileHeader) (string, error) {
	// ファイルを開く
	src, err := file.Open()
	if err != nil {
		return "", fmt.Errorf("failed to open file: %w", err)
	}
	defer src.Close()

	// ファイル名を生成
	ext := filepath.Ext(file.Filename)
	filename := fmt.Sprintf("%s%s", uuid.New().String(), ext)
	key := fmt.Sprintf("uploads/%s/%s", time.Now().Format("2006/01/02"), filename)

	// S3にアップロード
	_, err = s.client.PutObject(ctx, &s3.PutObjectInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(key),
		Body:   src,
	})
	if err != nil {
		return "", fmt.Errorf("failed to upload file to S3: %w", err)
	}

	// S3のURLを返す
	return fmt.Sprintf("https://%s.s3.%s.amazonaws.com/%s", s.bucketName, s.region, key), nil
}

// Delete はS3からファイルを削除します
func (s *S3Storage) Delete(ctx context.Context, filePath string) error {
	// URLからキーを抽出
	key := filepath.Base(filePath)

	// S3から削除
	_, err := s.client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(key),
	})
	if err != nil {
		return fmt.Errorf("failed to delete file from S3: %w", err)
	}

	return nil
}

// GetSignedURL は署名付きURLを生成します
func (s *S3Storage) GetSignedURL(ctx context.Context, key string, duration time.Duration) (string, error) {
	presignClient := s3.NewPresignClient(s.client)

	request, err := presignClient.PresignGetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(key),
	}, s3.WithPresignExpires(duration))
	if err != nil {
		return "", fmt.Errorf("failed to generate signed URL: %w", err)
	}

	return request.URL, nil
}

// Download はS3からファイルをダウンロードします
func (s *S3Storage) Download(ctx context.Context, key string) (io.ReadCloser, error) {
	result, err := s.client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(key),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to download file from S3: %w", err)
	}

	return result.Body, nil
}
