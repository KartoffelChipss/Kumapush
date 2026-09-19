package service

import (
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/hex"
	"fmt"
)

const authTokenBytes = 32

// GenerateAuthToken returns a new random auth token together with the hash
// that should be persisted. The plain token is never stored.
func GenerateAuthToken() (token, hash string, err error) {
	raw := make([]byte, authTokenBytes)
	if _, err := rand.Read(raw); err != nil {
		return "", "", fmt.Errorf("failed to generate auth token: %w", err)
	}
	token = base64.RawURLEncoding.EncodeToString(raw)
	return token, HashAuthToken(token), nil
}

// HashAuthToken hashes an auth token for storage.
func HashAuthToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}

// AuthTokenMatches compares a presented token against a stored hash in constant time.
func AuthTokenMatches(token, storedHash string) bool {
	return subtle.ConstantTimeCompare([]byte(HashAuthToken(token)), []byte(storedHash)) == 1
}
