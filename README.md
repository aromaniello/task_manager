# Task Manager

Dependencies:
```bash
gem install json activerecord
```

To create and migrate the database, first input the correct credentials in `database.yml`, then run:
```bash
rake db:create
rake db:migrate
```

To import all tasks from the `tasks.json` file into the database:
```bash
rake load_tasks file_name.json

# for example:
rake load_tasks tasks.json
```

To export tasks for a certain deadline:
```bash
rake export_tasks deadline file_name file_format

# for example:
rake export_tasks next_week exported_tasks csv
```
Valid values for the first argument are `today`, `tomorrow` and `next_week`.  
Valid values for the third argument are `json` and `csv.`