package config

type Config struct {
	Port        string
	DatabaseURL string
}

func Load() *Config {
	return &Config{
		Port:        ":8080",
		DatabaseURL: "lunch.db",
	}
}
