*** Settings ***
Library           Screenshot
Library           RPA.Robocorp.WorkItems
Library           RPA.Tables
Library           Collections
Library           Sparepin
Library            RPA.Archive
Library    OperatingSystem


*** Keywords ***
Load and Process Order
    ${payload}=    Get Work Item Payload
    ${name}=    Set Variable    ${payload}[Order number]
    ${zip}=    Set Variable    ${payload}[Address]
    ${passed}=    Run Keyword And Return Status
    ...    OrderPartsFromDict    ${payload}
    IF    ${passed}
        #${file_path}=    Take Screenshot
        #Log    ${file_path}
        #Add Work Item File    ${file_path}    picture.jpg
        #Tämä lisaa work item variableen
        Set Work Item Variable    robotRunStatus    success
        Save Work Item
        #Tällä voidaan lisää dictiin
        #Set To Dictionary    ${payload}    successState=True
        #Create Output Work Item    variables=${payload}    save=True 
        Release Input Work Item    DONE
        
    ELSE
        Log    Order prosessing failed for: ${name} address: ${zip} payload: ${payload}    level=ERROR
        Set Work Item Variable    robotRunStatus    failed
        #Take Screenshot of failure, this could be taken from browser instead
        ${file_path}=    Take Screenshot
        Log    ${file_path}
        Add Work Item File    ${file_path}    picture.jpg
        Save Work Item
        Release Input Work Item
        ...    state=FAILED
        ...    exception_type=BUSINESS
        ...    message=Order prosessing failed for: ${name}
        Set To Dictionary    ${payload}    successState=False

    END 
   
 

*** Tasks ***
Load and Process All Orders
    [Documentation]    Orders all robots.
    ...    uses python library to order parts
    ...    After part order downloads pdf file
    ...    Also collects pdf files into zip package!
    For Each Input Work Item    Load and Process Order
    ${ZIPDIR}=    Archive Folder With Zip  ${OUTPUT_DIR}  allPdfs.zip        include=*.pdf
    Move File    allPdfs.zip     ${OUTPUT_DIR}${/}allPdfs.zip        
    


