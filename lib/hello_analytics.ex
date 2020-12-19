defmodule HelloAnalytics do
  def measure_users do
    :telemetry.execute([:hello, :users], %{total: Hello.Accounts.count_users()})
  end
end
