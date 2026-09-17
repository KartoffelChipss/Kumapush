package service

import "regexp"

var apnsTokenPattern = regexp.MustCompile(`^[a-fA-F0-9]{32,512}$`)

func IsValidAppleDeviceToken(token string) bool {
	return len(token)%2 == 0 && apnsTokenPattern.MatchString(token)
}
