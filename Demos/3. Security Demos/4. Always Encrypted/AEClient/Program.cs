using System;
using System.Data;
using Microsoft.Data.SqlClient;

namespace AEClient
{
	internal class Program
	{
		static void Main(string[] args)
		{
			RunDemo();
		}

		private const string PlainConnStr =
			"data source=.;initial catalog=MyEncryptedDB;integrated security=true;Trust Server Certificate=True;";

		private const string AeEnabledConnStr =
			PlainConnStr + "column encryption setting=enabled";

		public static void RunDemo()
		{
			System.Diagnostics.Debugger.Break();

			Console.WriteLine("*** Without Encryption Setting ***");
			Console.WriteLine();
			RunWithoutEncryptionSetting();

			Console.Clear();
			Console.WriteLine("*** With Encryption Setting (T-SQL) ***");
			Console.WriteLine();
			RunWithEncryptionSettingTSql();

			Console.Clear();
			Console.WriteLine("*** With Encryption Setting (stored procedures) ***");
			Console.WriteLine();
			RunWithEncryptionSettingStoredProcs();

			Console.WriteLine("Press any key to continue");
			Console.ReadKey();
		}

		private static void RunWithoutEncryptionSetting()
		{
			using var conn = new SqlConnection(PlainConnStr);
			conn.Open();

			// Can query, but can't read encrypted data returned by the query
			using (var cmd = new SqlCommand("SELECT * FROM Customer", conn))
			{
				using var rdr = cmd.ExecuteReader();

				while (rdr.Read())
				{
					var customerId = rdr["CustomerId"];
					var name = rdr["Name"];
					var ssn = rdr["SSN"];
					var city = rdr["City"];

					Console.WriteLine("CustomerId: {0}; Name: {1}; SSN: {2}; City: {3}",
						customerId, name, ssn, city);
				}

				rdr.Close();
				Console.WriteLine();
			}

			// Can't query on Name
			using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Customer WHERE Name = @Name", conn))
			{
				var parm = new SqlParameter("@Name", SqlDbType.VarChar, 20) { Value = "John Smith" };
				cmd.Parameters.Add(parm);

				try
				{
					cmd.ExecuteScalar();
				}
				catch (Exception ex)
				{
					Console.WriteLine("Failed to run query on Name column");
					Console.WriteLine(ex.Message);
					Console.WriteLine();
				}
			}

			// Can't query on SSN
			using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Customer WHERE SSN = @SSN", conn))
			{
				var parm = new SqlParameter("@SSN", SqlDbType.VarChar, 20) { Value = "n/a" };
				cmd.Parameters.Add(parm);

				try
				{
					cmd.ExecuteScalar();
				}
				catch (Exception ex)
				{
					Console.WriteLine("Failed to run query on SSN column");
					Console.WriteLine(ex.Message);
					Console.WriteLine();
				}
			}

			// Can't insert encrypted data
			using (var cmd = new SqlCommand("INSERT INTO Customer VALUES(@Name, @SSN, @City)", conn))
			{
				var nameParam = new SqlParameter("@Name", SqlDbType.VarChar, 20) { Value = "Steven Jacobs" };
				cmd.Parameters.Add(nameParam);

				var ssnParam = new SqlParameter("@SSN", SqlDbType.VarChar, 20) { Value = "333-22-4444" };
				cmd.Parameters.Add(ssnParam);

				var cityParam = new SqlParameter("@City", SqlDbType.VarChar, 20) { Value = "Los Angeles" };
				cmd.Parameters.Add(cityParam);

				try
				{
					cmd.ExecuteNonQuery();
				}
				catch (Exception ex)
				{
					Console.WriteLine("Failed to insert new row with encrypted data");
					Console.WriteLine(ex.Message);
					Console.WriteLine();
				}
			}
			conn.Close();

			Console.WriteLine();
		}

		private static void RunWithEncryptionSettingTSql()
		{
			using var conn = new SqlConnection(AeEnabledConnStr);
			conn.Open();

			// Encrypted data gets decrypted after being returned by the query
			using (var cmd = new SqlCommand("SELECT * FROM Customer", conn))
			{
				using var rdr = cmd.ExecuteReader();
				while (rdr.Read())
				{
					var customerId = rdr["CustomerId"];
					var name = rdr["Name"];
					var ssn = rdr["SSN"];
					var city = rdr["City"];

					Console.WriteLine("CustomerId: {0}; Name: {1}; SSN: {2}; City: {3}",
						customerId, name, ssn, city);
				}
				rdr.Close();
				Console.WriteLine();
			}

			// Can't query on Name, even with column encryption setting, because it uses randomized encryption
			using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Customer WHERE Name = @Name", conn))
			{
				var parm = new SqlParameter("@Name", SqlDbType.VarChar, 20) { Value = "John Smith" };
				parm.Value = "John Smith";
				cmd.Parameters.Add(parm);

				try
				{
					cmd.ExecuteScalar();
				}
				catch (Exception ex)
				{
					Console.WriteLine("Failed to run query on Name column");
					Console.WriteLine(ex.Message);
					Console.WriteLine();
				}
			}

			// Can query on SSN, because it uses deterministic encryption
			using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Customer WHERE SSN = @SSN", conn))
			{
				var parm = new SqlParameter("@SSN", SqlDbType.VarChar, 20) { Value = "n/a" };
				cmd.Parameters.Add(parm);

				var result = (int)cmd.ExecuteScalar();
				Console.WriteLine("SSN 'n/a' count = {0}", result);

				// However, the search is not case sensitive, and won't match "N/A" with "n/a"
				parm.Value = "N/A";
				result = (int)cmd.ExecuteScalar();
				Console.WriteLine("SSN 'N/A' count = {0}", result);
			}
			Console.WriteLine();

			// Can never run a range query, even when using deterministic encryption
			using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Customer WHERE SSN >= @SSN", conn))
			{
				var parm = new SqlParameter("@SSN", SqlDbType.VarChar, 20) { Value = "500-000-0000" };
				cmd.Parameters.Add(parm);

				try
				{
					cmd.ExecuteScalar();
				}
				catch (Exception ex)
				{
					Console.WriteLine("Failed to run range query on SSN column");
					Console.WriteLine(ex.Message);
					Console.WriteLine();
				}
			}

			// Can insert encrypted data
			using (var cmd = new SqlCommand("INSERT INTO Customer VALUES(@Name, @SSN, @City)", conn))
			{
				var nameParam = new SqlParameter("@Name", SqlDbType.VarChar, 20) { Value = "Steven Jacobs" };
				cmd.Parameters.Add(nameParam);

				var ssnParam = new SqlParameter("@SSN", SqlDbType.VarChar, 20) { Value = "333-22-4444" };
				cmd.Parameters.Add(ssnParam);

				var cityParam = new SqlParameter("@City", SqlDbType.VarChar, 20) { Value = "Los Angeles" };
				cmd.Parameters.Add(cityParam);

				cmd.ExecuteNonQuery();
				Console.WriteLine("Successfully inserted new row with encrypted data");
				Console.WriteLine();
			}

			conn.Close();
		}

		private static void RunWithEncryptionSettingStoredProcs()
		{
			using var conn = new SqlConnection(AeEnabledConnStr);
			conn.Open();

			// Retrieve encrypted columns using stored procedure
			using (var cmd = conn.CreateCommand())
			{
				cmd.CommandText = "SelectCustomers";
				cmd.CommandType = CommandType.StoredProcedure;

				using var rdr = cmd.ExecuteReader();
				while (rdr.Read())
				{
					var customerId = rdr["CustomerId"];
					var name = rdr["Name"];
					var ssn = rdr["SSN"];
					var city = rdr["City"];

					Console.WriteLine("CustomerId: {0}; Name: {1}; SSN: {2}; City: {3}",
						customerId, name, ssn, city);
				}
				rdr.Close();
				Console.WriteLine();
			}

			// Select encrypted columns using stored procedure by query on deterministically encrypted column
			using (var cmd = conn.CreateCommand())
			{
				cmd.CommandText = "SelectCustomersBySsn";
				cmd.CommandType = CommandType.StoredProcedure;

				// note... cmd.Parameters.AddWithValue will *not* work for AE
				cmd.Parameters.Add(new SqlParameter("@SSN", SqlDbType.VarChar, 20) { Value = "n/a" });

				using var rdr = cmd.ExecuteReader();
				while (rdr.Read())
				{
					var customerId = rdr["CustomerId"];
					var name = rdr["Name"];
					var ssn = rdr["SSN"];
					var city = rdr["City"];

					Console.WriteLine("CustomerId: {0}; Name: {1}; SSN: {2}; City: {3}",
						customerId, name, ssn, city);
				}
				rdr.Close();
				Console.WriteLine();
			}

			// Insert encrypted columns using stored procedure
			using (var cmd = conn.CreateCommand())
			{
				cmd.CommandText = "InsertCustomer";
				cmd.CommandType = CommandType.StoredProcedure;

				cmd.Parameters.Add(new SqlParameter("@Name", SqlDbType.VarChar, 20) { Value = "Marcy Jones" });     // Length must match table definition
				cmd.Parameters.Add(new SqlParameter("@SSN", SqlDbType.VarChar, 20) { Value = "888-88-8888" });      // Length must match table definition
				cmd.Parameters.Add(new SqlParameter("@City", SqlDbType.VarChar) { Value = "Atlanta" });
				cmd.Parameters.Add(new SqlParameter("@CustomerId", SqlDbType.Int) { Direction = ParameterDirection.Output });

				cmd.ExecuteNonQuery();
				Console.WriteLine("Created new customer: {0}", cmd.Parameters["@CustomerId"].Value);
				Console.WriteLine();
			}

			conn.Close();
		}

	}
}
