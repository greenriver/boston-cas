// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

/////////////////////
// Vendor libs
////////////////////
//= require jquery
//= require popper
//= require bootstrap
//= require moment
//= require jquery_ujs
//= require handlebars.runtime
//= require select2-full
//= require bootstrap-datepicker
//= require bootstrap-datetimepicker
//= require jquery.periodicalupdater
//= require jquery.updater

//////////////////////////
// App specific code
//////////////////////////
//= require namespace
//= require_tree ./templates
//= require pjax-modals
//= require acknowledge_notification
//= require_tree ./contact_manager
//= require_tree ./requirement_manager
//= require_tree ./service_manager
//= require_tree ./matches
//= require_tree ./users
//= require enhanced_submit_param
//= require site_menu
//= require single_option_checkboxes
//= require section_toggle

//= require init
