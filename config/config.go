package config

type Config struct {
	ApiPort       string
	DashboardPort string
}

func Load() *Config {
	return &Config{
		ApiPort:       ":4040",
		DashboardPort: ":8080",
	}
}
