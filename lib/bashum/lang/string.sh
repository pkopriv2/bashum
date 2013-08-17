# Returns a random string of the given length.
str_random() {
	env LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom | head -c ${1:-8}
}
