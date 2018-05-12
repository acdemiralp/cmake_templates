function   (add_conan_remote NAME ADDRESS USERNAME API_KEY)
  execute_process(COMMAND conan remote add ${NAME} ${ADDRESS} OUTPUT_QUIET ERROR_QUIET)
  execute_process(COMMAND conan user -p ${API_KEY} -r ${NAME} ${USERNAME} OUTPUT_QUIET ERROR_QUIET)
endfunction(add_conan_remote)
