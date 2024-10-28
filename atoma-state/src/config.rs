use config::Config;
use serde::{Deserialize, Serialize};
use std::path::Path;

/// Configuration for SQLite database connection.
#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct StateManagerConfig {
    /// The URL of the SQLite database.
    pub database_url: String,
}

impl StateManagerConfig {
    /// Constructor
    pub fn new(database_url: String) -> Self {
        Self { database_url }
    }

    /// Creates a new `StateManagerConfig` instance from a configuration file.
    ///
    /// # Arguments
    ///
    /// * `config_file_path` - A path-like object representing the location of the configuration file.
    ///
    /// # Returns
    ///
    /// Returns a new `StateManagerConfig` instance populated with values from the configuration file.
    ///
    /// # Panics
    ///
    /// This method will panic if:
    /// - The configuration file cannot be read or parsed.
    /// - The "atoma-state" section is missing from the configuration file.
    /// - The required fields are missing or have invalid types in the configuration file.
    ///
    /// # Examples
    ///
    /// ```rust,ignore
    /// use std::path::Path;
    /// use atoma_node::atoma_state::StateManagerConfig;
    ///
    /// let config = StateManagerConfig::from_file_path("path/to/config.toml");
    /// ```
    pub fn from_file_path<P: AsRef<Path>>(config_file_path: P) -> Self {
        let builder = Config::builder().add_source(config::File::with_name(
            config_file_path.as_ref().to_str().unwrap(),
        ));
        let config = builder
            .build()
            .expect("Failed to generate atoma state configuration file");
        config
            .get::<Self>("atoma-state")
            .expect("Failed to generate configuration instance")
    }
}