terraform {
  source = "../home"
}
include "root"{
	path = find_in_parent_folders()
}
inputs = { 
}