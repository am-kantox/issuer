# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :issuer, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:issuer, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info

config :issuer, :vcs, [
  engine: :github,
  user:   :"am-kantox",
  repo:   :issuer,
  token:  'KVbclz6Ln7lgEDsc1aI4FscIuTVO0e7yWgj3Jn33Ckt05674Q3mbKAbkIRRKDy0fXF7SDi0qAkBZetNld8uXPRh+hUaiRtNvwm2l9ISY96HE2mnGISGFYz3lf4/sKGoUyKhZvvOk2Vvee5JVAlcH7oXydMhabTyudi5iNCU4+l9lvb7y8dCJPXFmTDk4lMseOdDuXpDR7CU99mb1FF+vxBYpRhEp1cgYAB3IarcIHDCe8KH9gkQ9S/hMX4BAJn3UPXm7+/UZoMUzm+6kBBx2WIIroAk2lVE3K2rDipWHEfLn1xIcWqZgGd36pZN7NFcxPCzIK+lv2ZWheKyLsTPpr+ZOmP7vZoIMVGZgop/YaQVg2VZ5BXhJsQkesCu63yGKwWGeJs/rSHpJntNNCV0B5lua5nv2pl3/EVHI6qwdxcDsL1DsAFL20wOk+cWQvpobpS6YwfqKUAuL9thCDCPAsVHmfFFEavsyjhdoHsNZD6TnzD5NMPKyWblGJmQHIBVfUk2itbpY3gs/Z1Dbsd5GbyUPen1zboq3T5Svwh/uqFsLcsFeTb1RGs/hrcU+W74Ur408oSMRAjxTdyWdUrTAOpkqSsEW0UVaD2N0v1fSOjY6kG8rX5qjb01lXVnxi4kZNxuU41c+DW2iDI45Wx2kg3DMCv7W8Rb33kICDc/9w6Y='
]

config :issuer, :identity, [
  prv: "/home/am/.ssh/id_rsa_kantox",
  pub: "/home/am/.ssh/id_rsa_kantox.pub",
  pem: "/home/am/.ssh/id_rsa_kantox.pub.pem"
]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
