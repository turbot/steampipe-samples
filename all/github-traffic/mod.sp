
	    mod "github-traffic" {
	    }
	    
	    dashboard "traffic" {
	
	    container {
	      title = "plugins"
	      
	      chart {
	        width = 2
	        title = "turbot/aws"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-aws'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/azure"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-azure'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/oci"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-oci'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/sdk"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-sdk'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/alicloud"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-alicloud'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/github"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-github'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/gcp"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-gcp'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/snowflake"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-snowflake'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/net"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-net'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/csv"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-csv'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/kubernetes"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-kubernetes'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/azuread"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-azuread'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/slack"
	        axes {
	          y {
	              max = 25
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-slack'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	    }
	
	    container {
	      title = "mods"
	      
	      chart {
	        width = 2
	        title = "turbot/aws-compliance"
	        axes {
	          y {
	              max = 23
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-aws-compliance'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/aws-insights"
	        axes {
	          y {
	              max = 23
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-aws-insights'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/azure-compliance"
	        axes {
	          y {
	              max = 23
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-azure-compliance'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/aws-thrifty"
	        axes {
	          y {
	              max = 23
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-aws-thrifty'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/alicloud-insights"
	        axes {
	          y {
	              max = 23
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-alicloud-insights'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/azure-insights"
	        axes {
	          y {
	              max = 23
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-azure-insights'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/gcp-compliance"
	        axes {
	          y {
	              max = 23
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-gcp-compliance'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/snowflake-compliance"
	        axes {
	          y {
	              max = 23
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-snowflake-compliance'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/gcp-insights"
	        axes {
	          y {
	              max = 23
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-gcp-insights'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/net-insights"
	        axes {
	          y {
	              max = 23
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-net-insights'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	    }
	
	  }
	  