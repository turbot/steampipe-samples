variable "valid_sessions" {
  type = list(string)
  default = ["101","102","103","104","105","201","202","203","204","205"]
}

control "sessions_valid_in_session_table" {
  title = "Sessions in the sessions table are valid"
  sql = <<EOT
    select
      'event planner' as resource,
        case
            when (
              session = any( $1 )  
            ) then 'ok'
            else 'alarm'
        end as status,
      'Session ' || session as reason
    from
      csv.sessions
  EOT
  param "valid_sessions" {
    default = var.valid_sessions
  }
}

control "sessions_valid_in_people_table" {
  title = "Sessions in the people table are valid"
  sql = <<EOT
    with person_session as (
      select
        person,
        string_to_array(
          regexp_replace(sessions, '\s', '', 'g'),
          ','
          ) as sessions
        from csv.people
        ),
    unnested as (
      select
        unnest(sessions) as session
      from
        person_session
    )
    select distinct
      'event planner' as resource,
        case
            when (
              session = any( $1 )
            ) then 'ok'
            else 'alarm'
        end as status,
      'Session ' || session as reason
    from unnested
  EOT
  param "valid_sessions" {
    default = var.valid_sessions
  }
}
