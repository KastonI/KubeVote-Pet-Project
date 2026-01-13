using System;
using System.Data.Common;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using Newtonsoft.Json;
using Npgsql;
using StackExchange.Redis;

namespace Worker
{
    public class Program
    {
        static string Env(string key, string def)
            => Environment.GetEnvironmentVariable(key) ?? def;

        public static int Main(string[] args)
        {
            try
            {
                // ===== ENV CONFIG =====
                string redisHost = Env("REDIS_HOST", "redis");
                string redisPort = Env("REDIS_PORT", "6379");

                string pgHost = Env("POSTGRES_HOST", "db");
                string pgUser = Env("POSTGRES_USER", "postgres");
                string pgPassword = Env("POSTGRES_PASSWORD", "postgres");
                string pgDb = Env("POSTGRES_DB", "postgres");

                string redisEndpoint = $"{redisHost}:{redisPort}";
                string pgConnString = $"Server={pgHost};Username={pgUser};Password={pgPassword};Database={pgDb};";

                Console.WriteLine($"Redis: {redisEndpoint}");
                Console.WriteLine($"Postgres: {pgHost}/{pgDb}");

                // ===== CONNECTIONS =====
                var pgsql = OpenDbConnection(pgConnString);
                var redisConn = OpenRedisConnection(redisEndpoint);
                var redis = redisConn.GetDatabase();

                var definition = new { vote = "", voter_id = "" };

                Console.WriteLine("Worker started");

                while (true)
                {
                    // Slow down to prevent CPU spike, only query each 100ms
                    Thread.Sleep(100);

                    // Reconnect redis if down
                    if (redisConn == null || !redisConn.IsConnected) {
                        Console.WriteLine("Reconnecting Redis");
                        redisConn = OpenRedisConnection("redis");
                        redis = redisConn.GetDatabase();
                    }
                    string json = redis.ListLeftPopAsync("votes").Result;
                    if (json != null)
                    {
                        var vote = JsonConvert.DeserializeAnonymousType(json, definition);
                        Console.WriteLine($"Processing vote for '{vote.vote}' by '{vote.voter_id}'");
                        // Reconnect DB if down
                        if (!pgsql.State.Equals(System.Data.ConnectionState.Open))
                        {
                            Console.WriteLine("Reconnecting DB");
                            pgsql = OpenDbConnection("Server=db;Username=postgres;Password=postgres;");
                        }
                        else
                        { // Normal +1 vote requested
                            UpdateVote(pgsql, vote.voter_id, vote.vote);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine(ex.ToString());
                return 1;
            }
        }

        private static NpgsqlConnection OpenDbConnection(string connectionString)
        {
            NpgsqlConnection connection;

            while (true)
            {
                try
                {
                    connection = new NpgsqlConnection(connectionString);
                    connection.Open();
                    break;
                }
                catch (SocketException)
                {
                    Console.Error.WriteLine("Waiting for db");
                    Thread.Sleep(1000);
                }
                catch (DbException)
                {
                    Console.Error.WriteLine("Waiting for db");
                    Thread.Sleep(1000);
                }
            }

            Console.Error.WriteLine("Connected to db");

            var command = connection.CreateCommand();
            command.CommandText = @"CREATE TABLE IF NOT EXISTS votes (
                                        id VARCHAR(255) NOT NULL UNIQUE,
                                        vote VARCHAR(255) NOT NULL
                                    )";
            command.ExecuteNonQuery();

            return connection;
        }

private static ConnectionMultiplexer OpenRedisConnection(string endpoint)
{
    while (true)
    {
        try
        {
            Console.WriteLine($"Connecting to Redis at {endpoint}");
            return ConnectionMultiplexer.Connect(endpoint);
        }
        catch (RedisConnectionException)
        {
            Console.WriteLine("Waiting for Redis...");
            Thread.Sleep(1000);
        }
    }
}


        private static void UpdateVote(NpgsqlConnection connection, string voterId, string vote)
        {
            var command = connection.CreateCommand();
            try
            {
                command.CommandText = "INSERT INTO votes (id, vote) VALUES (@id, @vote)";
                command.Parameters.AddWithValue("@id", voterId);
                command.Parameters.AddWithValue("@vote", vote);
                command.ExecuteNonQuery();
            }
            catch (DbException)
            {
                command.CommandText = "UPDATE votes SET vote = @vote WHERE id = @id";
                command.ExecuteNonQuery();
            }
            finally
            {
                command.Dispose();
            }
        }
    }
}