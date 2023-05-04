dashboard "TasksAndSubtasks" {

  graph {

    node {
      category = category.task
      sql = <<EOQ
        select
          title as id,
          title,
          json_build_object(
            'summary', summary,
            'url', '${local.server}/jira/core/projects/IDD/board?selectedIssue=' || title
          ) as properties
        from
          jira_issue
        where
          type = 'Task'
      EOQ
    }

    node {
      category = category.subtask
      sql = <<EOQ
        select
          title as id,
          title,
          json_build_object(
            'summary', summary,
            'url', '${local.server}/jira/core/projects/IDD/board?selectedIssue=' || title
          ) as properties
        from
          jira_issue
        where
          type = 'Sub-task'
      EOQ
    }

    edge {
      sql = <<EOQ
        select
          fields->'parent'->>'key' as from_id,
          title as to_id
          from
            jira_issue
          where
            fields->'parent' is not null
      EOQ
    }

  }

  table {
    sql = <<EOQ
      select
        title,
        type,
        summary,
        fields->'parent'->>'key' as parent
      from
        jira_issue
    EOQ
  }

}

category "task" {
  icon = "task"
  color = "black"
  href  = "{{.properties.'url'}}"
}

category "subtask" {
  icon = "task"
  color = "gray"
  href  = "{{.properties.'url'}}"
}