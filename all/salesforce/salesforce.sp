dashboard "salesforce" {

  tags = {
    service = "salesforce"
  }

  container {

    card {
      width = 2
      sql = <<EOQ
        select count(*) as contacts from salesforce_contact
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select count(*) as leads from salesforce_lead
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select count(*) as products from salesforce_product
      EOQ
    }

    
  }

  container {

    chart {
      width = 4
      type = "donut"
      title = "contacts by lead source"
      sql = <<EOQ
        select
          lead_source,
          count(*)
        from 
          salesforce_contact
        where
          lead_source is not null
        group by
          lead_source
      EOQ
    }

    container {
      width = 8

      input "search_name" {
        title = "search names"
        width = 3
        type = "text"
        placeholder = "Any"
      }

      input "lead_source" {
        title = "by lead_source"
        width = 3
        type = "select"
        sql = <<EOQ
          with data as (
            select 
              lead_source,
              count(*)
            from
              salesforce_contact
            where
              lead_source is not null
            group by
              lead_source
          )
          select
            'All (' || (select count(*) from data) || ')' as label,
            'All' as value
          union
          select
            lead_source || ' (' || count || ')' as label,
            lead_source as value
          from 
            data
          order by label
        EOQ
      }

      table {
        args = [
          self.input.lead_source
        ]
        sql = <<EOQ
          select 
            name,
            title,
            lead_source,
            created_date
          from
            salesforce_contact
          where
            lead_source = 
              case 
                when $1 ~ '^All' then ''
                else $1
              end
          order by 
            created_date desc
        EOQ
      }

    }

  }


  table {
    sql = <<EOQ
      select * from salesforce_product
    EOQ
  }

  table {
    sql = <<EOQ
      select * from salesforce_user
    EOQ
  }

  table {
    sql = <<EOQ
      select * from salesforce_user
    EOQ
  }

}
