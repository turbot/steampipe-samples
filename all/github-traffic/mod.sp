
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
	              max = 69
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
	        title = "turbot/panos"
	        axes {
	          y {
	              max = 69
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-panos'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/azure"
	        axes {
	          y {
	              max = 69
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
	        title = "turbot/github"
	        axes {
	          y {
	              max = 69
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
	        title = "turbot/kubernetes"
	        axes {
	          y {
	              max = 69
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
	        title = "turbot/oci"
	        axes {
	          y {
	              max = 69
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
	              max = 69
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
	        title = "turbot/gcp"
	        axes {
	          y {
	              max = 69
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
	        title = "turbot/terraform"
	        axes {
	          y {
	              max = 69
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-plugin-terraform'
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
	              max = 20
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
	              max = 20
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
	        title = "turbot/aws-thrifty"
	        axes {
	          y {
	              max = 20
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
	        title = "turbot/kubernetes-insights"
	        axes {
	          y {
	              max = 20
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-kubernetes-insights'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/azure-compliance"
	        axes {
	          y {
	              max = 20
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
	        title = "turbot/terraform-oci-compliance"
	        axes {
	          y {
	              max = 20
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-terraform-oci-compliance'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/oci-compliance"
	        axes {
	          y {
	              max = 20
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-oci-compliance'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	      chart {
	        width = 2
	        title = "turbot/gcp-compliance"
	        axes {
	          y {
	              max = 20
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
	        title = "turbot/ibm-insights"
	        axes {
	          y {
	              max = 20
	            }
	          }
	        sql = <<EOT
	          select
	            to_char(timestamp, 'MM-DD'),
	            uniques
	          from
	            github_traffic_view_daily
	          where
	            repository_full_name = 'turbot/steampipe-mod-ibm-insights'
	          order by
	            timestamp;    
	        EOT
	      }
	    
	    }
	
	  }
	  