dir_classes_pattern="force-app/main/default/classes/"
dir_lwc_pattern="force-app/main/default/lwc/"
extension_cls="cls"
extension_cls_meta_xml="cls-meta.xml"
extension_html="html"
extension_css="css"
extension_js="js"
extension_js_meta_xml="js-meta.xml"
extensions_of_lwc_components=("$extension_html" "$extension_css" "$extension_js" "$extension_js_meta_xml")

files_from_dir_classes=()
files_from_dir_lwc=()
max_count_of_files_in_lwc_component_directory=4

file_name_pairs_for_unpaired_file_names_from_array__files_from_dir_classes=()
file_name_pairs_for_unpaired_file_names_from_array__files_from_dir_lwc=()


function get_file_name() {
  local full_file_name=$1
  local file_name=${full_file_name##*\/}
  echo $file_name
}

function get_file_name_from_dir_lwc() {
  local full_file_name=$1
  local file_name=${full_file_name##*$dir_lwc_pattern}
  echo $file_name
}

function get_file_name_without_extension() {
  local file_name=$1
  local file_name_without_extension=${file_name%%\.*}
  echo $file_name_without_extension
}

function get_file_extension() {
  local file_name=$1
  local file_extension=${file_name#*\.}
  echo $file_extension
}

function get_path_without_file_name() {
  local full_file_name=$1
  local path_without_file_name="${full_file_name%\/*}/"
  echo $path_without_file_name
}

function get_index_of_paired_file_by_extension() {
  local verifiable_file_name_without_extension=$1
  local extension=$2
  local paired_index="-1"
  for (( j=0; j<${#files_from_dir_classes[@]}; j++ )); do
    local current_file_name=$(get_file_name ${files_from_dir_classes[j]})
    local current_file_name_without_extension=$(get_file_name_without_extension $current_file_name)
    local current_file_extension=$(get_file_extension $current_file_name)
    if [[ "$verifiable_file_name_without_extension" == "$current_file_name_without_extension" && "$current_file_extension" == "$extension" ]]; then
      paired_index=$j
      break
    fi
  done
  echo $paired_index
}

function delete_paired_file_names_from_array__files_from_dir_classes() {
  for (( i=0; i<${#files_from_dir_classes[@]}; i++ )); do
    local file_name=$(get_file_name ${files_from_dir_classes[i]})
    local file_name_without_extension=$(get_file_name_without_extension $file_name)
    local file_extension=$(get_file_extension $file_name)

    local paired_element_array_index="-1"
    if [[ "$file_extension" == "$extension_cls" ]]; then
      paired_element_array_index=$(get_index_of_paired_file_by_extension "$file_name_without_extension" "$extension_cls_meta_xml")
    fi

    if [[ "$file_extension" == "$extension_cls_meta_xml" ]]; then
      paired_element_array_index=$(get_index_of_paired_file_by_extension "$file_name_without_extension" "$extension_cls")
    fi

    if [[ "$paired_element_array_index" -ge "0" ]]; then
      local indexes_to_delete=("$i" "$paired_element_array_index")
        for j in "${indexes_to_delete[@]}"; do
          unset "files_from_dir_classes[$j]"
      done
      files_from_dir_classes=("${files_from_dir_classes[@]}")
    fi
  done
}

function get_paired_file_names_for_unpaired_file_names_from_array__files_from_dir_classes() {
  for (( i=0; i<${#files_from_dir_classes[@]}; i++ )); do
    local path_without_file_name=$(get_path_without_file_name ${files_from_dir_classes[i]})
    local file_name=$(get_file_name ${files_from_dir_classes[i]})
    local file_name_without_extension=$(get_file_name_without_extension $file_name)
    local file_extension=$(get_file_extension $file_name)

    local paired_full_file_name="${path_without_file_name}${file_name_without_extension}"
    if [[ "$file_extension" == "$extension_cls" ]]; then
      paired_full_file_name="${paired_full_file_name}.${extension_cls_meta_xml}"
    fi

    if [[ "$file_extension" == "$extension_cls_meta_xml" ]]; then
      paired_full_file_name="${paired_full_file_name}.${extension_cls}"
    fi
    file_name_pairs_for_unpaired_file_names_from_array__files_from_dir_classes+=( $paired_full_file_name )
  done
}

function get_paired_file_names_for_unpaired_file_names_from_array__files_from_dir_lwc() {
  for (( i=0; i<${#files_from_dir_lwc[@]}; i++ )); do
    local verifiable_file_name=$(get_file_name_from_dir_lwc ${files_from_dir_lwc[i]})
    local verifiable_file_name_without_extension=$(get_file_name_without_extension $verifiable_file_name)
    local verifiable_file_extension=$(get_file_extension $verifiable_file_name)
    local paired_files_indexes=()

    for (( j=0; j<${#files_from_dir_lwc[@]}; j++ )); do
      local current_file_name=$(get_file_name_from_dir_lwc ${files_from_dir_lwc[j]})
      local current_file_name_without_extension=$(get_file_name_without_extension $current_file_name)
      local current_file_extension=$(get_file_extension $current_file_name)

      if [[ "$i" -ne "$j" && "$verifiable_file_name_without_extension" == "$current_file_name_without_extension" && "$current_file_extension" == "$extension_css" ]]; then
        paired_files_indexes+=( $j )
      fi

      if [[ "$i" -ne "$j" && "$verifiable_file_name_without_extension" == "$current_file_name_without_extension" && "$current_file_extension" == "$extension_html" ]]; then
        paired_files_indexes+=( $j )
      fi

      if [[ "$i" -ne "$j" && "$verifiable_file_name_without_extension" == "$current_file_name_without_extension" && "$current_file_extension" == "$extension_js" ]]; then
        paired_files_indexes+=( $j )
      fi

      if [[ "$i" -ne "$j" && "$verifiable_file_name_without_extension" == "$current_file_name_without_extension" && "$current_file_extension" == "$extension_js_meta_xml" ]]; then
        paired_files_indexes+=( $j )
      fi
    done

    if [[ ${#paired_files_indexes[@]} -lt $((max_count_of_files_in_lwc_component_directory-1)) && ${#paired_files_indexes[@]} -gt 0 ]]; then
      copy_paired_files_indexes=("${paired_files_indexes[@]}")
      copy_paired_files_indexes+=( "$i" )
      copy_of_extensions_of_lwc_components=("${extensions_of_lwc_components[@]}")
      for (( t=0; t<${#copy_paired_files_indexes[@]}; t++ )); do
        local file_name=$(get_file_name_from_dir_lwc ${files_from_dir_lwc[copy_paired_files_indexes[t]]})
        local file_extension=$(get_file_extension $file_name)

        for (( k=0; k<${#copy_of_extensions_of_lwc_components[@]}; k++ )); do
          if [[ "$file_extension" == "${copy_of_extensions_of_lwc_components[k]}" ]]; then
            unset "copy_of_extensions_of_lwc_components[$k]"
          fi
        done
        copy_of_extensions_of_lwc_components=("${copy_of_extensions_of_lwc_components[@]}")
      done

      for (( k=0; k<${#copy_of_extensions_of_lwc_components[@]}; k++ )); do
        file_name_pairs_for_unpaired_file_names_from_array__files_from_dir_lwc+=( "${dir_lwc_pattern}${verifiable_file_name_without_extension}.${copy_of_extensions_of_lwc_components[k]}" )
      done
    fi

    if [[ ${#paired_files_indexes[@]} -eq 0 ]]; then
      for (( t=0; t<${#extensions_of_lwc_components[@]}; t++ )); do
        local ext=${extensions_of_lwc_components[t]}
        if [[ "$ext" != "$verifiable_file_extension" ]]; then
          file_name_pairs_for_unpaired_file_names_from_array__files_from_dir_lwc+=( "${dir_lwc_pattern}${verifiable_file_name_without_extension}.${ext}" )
        fi
      done
    fi

      for index in "${paired_files_indexes[@]}"; do
        unset "files_from_dir_lwc[$index]"
    done
    files_from_dir_lwc=("${files_from_dir_lwc[@]}")
  done
}

while IFS= read -r full_file_name || [ -n "$full_file_name" ]; do
  path_without_file_name=$(get_path_without_file_name $full_file_name)

  if [[ "$path_without_file_name" == "$dir_classes_pattern" ]]; then
    files_from_dir_classes+=( $full_file_name )
  fi

  if [[ "$path_without_file_name" =~ "$dir_lwc_pattern"* ]]; then
    files_from_dir_lwc+=( $full_file_name )
  fi
done < diffFile.txt

echo "Hello World"

printf "\n%s\n" "files_from_dir_classes:"
for (( i=0; i<${#files_from_dir_classes[@]}; i++ )); do
  printf "%s = %s\n" "$i" "${files_from_dir_classes[i]}";
done

printf "\n%s\n" "files_from_dir_lwc:"
for (( i=0; i<${#files_from_dir_lwc[@]}; i++ )); do
  printf "%s = %s\n" "$i" "${files_from_dir_lwc[i]}";
done

if [ ${#files_from_dir_classes[@]} -gt 0 ]; then
  delete_paired_file_names_from_array__files_from_dir_classes
  if [ ${#files_from_dir_classes[@]} -gt 0 ]; then
    get_paired_file_names_for_unpaired_file_names_from_array__files_from_dir_classes
  fi
fi

resultArray+=("${file_name_pairs_for_unpaired_file_names_from_array__files_from_dir_classes[@]}")

if [ ${#files_from_dir_lwc[@]} -gt 0 ]; then
  get_paired_file_names_for_unpaired_file_names_from_array__files_from_dir_lwc
  resultArray+=("${file_name_pairs_for_unpaired_file_names_from_array__files_from_dir_lwc[@]}")
fi

printf "%s\n" "${resultArray[@]}" > missing_files.txt