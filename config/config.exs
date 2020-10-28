import Config

# Mix messages in colors...
config :elixir, ansi_enabled: true

# Listed by ascending log level...
config :logger, :console,
  colors: [
    debug: :light_cyan,
    info: :light_green,
    warn: :light_yellow,
    error: :light_red
  ]

format = "$date $time [$level] $levelpad$message\n"

error_path = "./log/error.log"
info_path = "./log/info.log"
warn_path = "./log/warn.log"

config :logger, :error_log, format: format, path: error_path, level: :error
config :logger, :info_log, format: format, path: info_path, level: :info
config :logger, :warn_log, format: format, path: warn_path, level: :warn

config :logger,
  backends: [
    # :console,
    {LoggerFileBackend, :error_log},
    {LoggerFileBackend, :info_log},
    {LoggerFileBackend, :warn_log}
  ]

# Purges debug messages...
config :logger, compile_time_purge_matching: [[level_lower_than: :info]]

# Keeps only error messages...
# config :logger, compile_time_purge_matching: [[level_lower_than: :error]]

# Uncomment to stop logging...
# config :logger, level: :error

import_config "persist_course_ref.exs"
import_config "persist_ets_name.exs"
