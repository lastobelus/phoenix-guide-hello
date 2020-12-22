defmodule HelloWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      # group routes by method and route using
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:method, :route],
        tag_values: &get_and_put_http_method/1,
        unit: {:native, :millisecond}
      ),
      summary("phoenix.live_view.mount.stop.duration",
        unit: {:native, :millisecond},
        tags: [:view, :connected?],
        tag_values: &live_view_metric_tag_values/1
      ),
      # Database Metrics
      summary("hello.repo.query.total_time", unit: {:native, :millisecond}),
      summary("hello.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("hello.repo.query.query_time", unit: {:native, :millisecond}),
      summary("hello.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("hello.repo.query.idle_time", unit: {:native, :millisecond}),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # Hello Metrics
      last_value("hello.users.total"),
      # ExampleServer Metrics
      last_value("hello.example_server.memory", unit: :byte),
      last_value("hello.example_server.message_queue_len"),
      summary("hello.example_server.call.stop.duration"),
      counter("hello.example_server.call.exception")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      {HelloAnalytics, :measure_users, []},
      {:process_info,
       event: [:hello, :example_server],
       name: Hello.ExampleServer,
       keys: [:message_queue_len, :memory]}
    ]
  end

  defp get_and_put_http_method(%{conn: %{method: method}} = metadata) do
    Map.put(metadata, :method, method)
  end

  defp live_view_metric_tag_values(metadata) do
    metadata
    |> Map.put(:view, inspect(metadata.socket.view))
    |> Map.put(:connected?, get_connection_status(metadata.socket))
  end

  defp get_connection_status(%{connected?: true}), do: "Connected"
  defp get_connection_status(%{connected?: false}), do: "Disconnected"
end
