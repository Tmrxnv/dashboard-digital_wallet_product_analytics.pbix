{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# PostgreSQL Data Load\n",
    "\n",
    "Loads the processed customer analytics dataset into PostgreSQL and creates the `retention_queue` view.\n",
    "\n",
    "Use environment variables or enter the password securely. Never commit a real password to GitHub.\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "from getpass import getpass\n",
    "from pathlib import Path\n",
    "\n",
    "import pandas as pd\n",
    "from sqlalchemy import URL, create_engine, inspect, text\n",
    "\n",
    "PROJECT_ROOT = Path.cwd().parent if Path.cwd().name == \"notebooks\" else Path.cwd()\n",
    "DATA_PATH = PROJECT_ROOT / \"data\" / \"processed\" / \"digital_wallet_customer_segments.csv\"\n",
    "VIEW_SQL_PATH = PROJECT_ROOT / \"sql\" / \"02_create_retention_queue_view.sql\"\n"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 1. Connect to PostgreSQL\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "db_password = getpass(\"PostgreSQL password: \")\n",
    "\n",
    "db_url = URL.create(\n",
    "    drivername=\"postgresql+psycopg2\",\n",
    "    username=\"postgres\",\n",
    "    password=db_password,\n",
    "    host=\"localhost\",\n",
    "    port=5432,\n",
    "    database=\"digital_wallet_analytics\"\n",
    ")\n",
    "\n",
    "engine = create_engine(db_url)\n",
    "\n",
    "with engine.connect() as connection:\n",
    "    database_name = connection.execute(\n",
    "        text(\"SELECT current_database();\")\n",
    "    ).scalar_one()\n",
    "\n",
    "print(\"Connected to:\", database_name)\n"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 2. Read the processed dataset\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "processed_df = pd.read_csv(DATA_PATH)\n",
    "\n",
    "print(\"Rows:\", len(processed_df))\n",
    "print(\"Blank age groups:\", processed_df[\"Age_Group\"].isna().sum())\n",
    "processed_df.head()\n"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 3. Load the table\n",
    "\n",
    "When the table already exists, `TRUNCATE + append` is used instead of `replace`. This preserves dependent PostgreSQL views.\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "table_name = \"customer_analytics\"\n",
    "schema = \"public\"\n",
    "table_exists = inspect(engine).has_table(table_name, schema=schema)\n",
    "\n",
    "if table_exists:\n",
    "    with engine.begin() as connection:\n",
    "        connection.execute(\n",
    "            text(\"TRUNCATE TABLE public.customer_analytics;\")\n",
    "        )\n",
    "    write_mode = \"append\"\n",
    "else:\n",
    "    write_mode = \"fail\"\n",
    "\n",
    "processed_df.to_sql(\n",
    "    name=table_name,\n",
    "    con=engine,\n",
    "    schema=schema,\n",
    "    if_exists=write_mode,\n",
    "    index=False,\n",
    "    chunksize=1000,\n",
    "    method=\"multi\"\n",
    ")\n",
    "\n",
    "print(\"Table loaded successfully.\")\n"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 4. Create the retention view\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "view_sql = VIEW_SQL_PATH.read_text(encoding=\"utf-8\")\n",
    "\n",
    "with engine.begin() as connection:\n",
    "    connection.exec_driver_sql(view_sql)\n",
    "\n",
    "print(\"View public.retention_queue created.\")\n"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 5. Validate the load\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "query = \"\"\"\n",
    "SELECT\n",
    "    COUNT(*) AS customers,\n",
    "    COUNT(*) FILTER (\n",
    "        WHERE \"Age_Group\" IS NULL\n",
    "    ) AS blank_age_groups\n",
    "FROM public.customer_analytics;\n",
    "\"\"\"\n",
    "\n",
    "pd.read_sql(query, engine)\n"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "name": "python",
   "version": "3.11"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}