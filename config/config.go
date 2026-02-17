package config

type Config struct {
	ApiPort       string
	DashboardPort string
}

func Load() *Config {
	return &Config{
		ApiPort:       ":8080",
		DashboardPort: ":8080",
	}
}
