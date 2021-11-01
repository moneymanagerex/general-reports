cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

function(create_zip output_file input_files working_dir)
    add_custom_command(
        COMMAND ${CMAKE_COMMAND} -E tar "cf" "${output_file}" --format=zip -- ${input_files} 
        WORKING_DIRECTORY "${working_dir}"
        OUTPUT  "${output_file}"
        DEPENDS ${input_files}
        COMMENT "Zipping to ${output_file}."
    )
endfunction()

# Build reports zip files
set(GRM_ACC_AccBal "${PROJECT_SOURCE_DIR}/general-reports/packages/Account/AccountBalances/description.txt"
                   "${PROJECT_SOURCE_DIR}/general-reports/packages/Account/AccountBalances/luacontent.lua"
                   "${PROJECT_SOURCE_DIR}/general-reports/packages/Account/AccountBalances/sqlcontent.sql"
                   "${PROJECT_SOURCE_DIR}/general-reports/packages/Account/AccountBalances/template.htt"
)
create_zip("${CMAKE_CURRENT_BINARY_DIR}/AccountBalances.grm" "${GRM_ACC_AccBal}" "${PROJECT_SOURCE_DIR}/general-reports/packages/Account/AccountBalances/")


add_custom_target(generate_res_default ALL DEPENDS  "${CMAKE_CURRENT_BINARY_DIR}/AccountBalances.grm"
                                                     )
