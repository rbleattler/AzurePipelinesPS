function Get-APBuildList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline builds.

    .DESCRIPTION

    Returns a list of Azure Pipeline builds based on a filter query, if one is not provided the default will return all available builds for the project provided.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER RepositoryId

    If specified, filters to builds that built from this repository.

    .PARAMETER BuildIds

    A comma-delimited list that specifies the IDs of builds to retrieve.

    .PARAMETER BranchName

    If specified, filters to builds that built branches that built this branch.

    .PARAMETER QueryOrder

    The order in which builds should be returned.

    .PARAMETER DeletedFilter

    Indicates whether to exclude, include, or only return deleted builds.

    .PARAMETER MaxBuildsPerDefinition

    The maximum number of builds to return per definition.

    .PARAMETER ContinuationToken

    A continuation token, returned by a previous call to this method, that can be used to return the next set of builds.

    .PARAMETER Top

    The maximum number of builds to return.

    .PARAMETER Properties

    A comma-delimited list of properties to retrieve.

    .PARAMETER TagFilters

    A comma-delimited list of tags. If specified, filters to builds that have the specified tags.

    .PARAMETER ResultFilter
    
    If specified, filters to builds that match this result.

    .PARAMETER StatusFilter

    If specified, filters to builds that match this status.

    .PARAMETER ReasonFilter

    If specified, filters to builds that match this reason.

    .PARAMETER RequestedFor
	
    If specified, filters to builds requested for the specified user.

    .PARAMETER MaxTime
    	
    If specified, filters to builds requested for the specified user.

    .PARAMETER MinTime

    If specified, filters to builds that finished/started/queued after this date based on the queryOrder specified.

    .PARAMETER BuildNumber

    If specified, filters to builds that match this build number. Append * to do a prefix search.

    .PARAMETER Queues

    A comma-delimited list of queue IDs. If specified, filters to builds that ran against these queues.

    .PARAMETER Definitions

    A comma-delimited list of definition IDs. If specified, filters to builds for these definitions.

    .PARAMETER RepositoryType
	
    If specified, filters to builds that built from repositories of this type.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines build(s)

    .EXAMPLE

    C:\PS> Get-APBuildList -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/build/builds/list?view=vsts-rest-5.0
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByPersonalAccessToken')]
    Param
    (
        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [uri]
        $Instance,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Collection,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Project,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $ApiVersion,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Security.SecureString]
        $PersonalAccessToken,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter()]
        [string]
        $RepositoryId,

        [Parameter()]
        [int[]]
        $BuildIds,

        [Parameter()]
        [string]
        $BranchName,

        [Parameter()]
        [string]
        [ValidateSet('finishTimeAscending', 'finishTimeDescending', 'queueTimeAscending', 'queueTimeDescending', 'startTimeAscending', 'startTimeDescending')]
        $QueryOrder,

        [Parameter()]
        [ValidateSet('excludeDeleted', 'includeDeleted', 'onlyDeleted')]
        [string]
        $DeletedFilter,   
        
        [Parameter()]
        [int]
        $MaxBuildsPerDefinition,

        [Parameter()]
        [string]
        $ContinuationToken,

        [Parameter()]
        [int]
        $Top,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string[]]
        $TagFilters,

        [Parameter()]
        [ValidateSet('canceled', 'failed', 'none', 'partiallySucceeded', 'succeeded')]
        [string]
        $ResultFilter,

        [Parameter()]
        [ValidateSet('all', 'cancelling', 'completed', 'inProgress', 'none', 'notStarted', 'postponed')]
        [string]
        $StatusFilter,

        [Parameter()]
        [ValidateSet('all', 'batchedCI', 'buildCompletion', 'checkInShelveset', 'individualCI', 'manual', 'none', 'pullRequest', 'schedule', 'triggered', 'userCreated', 'validateShelveset')]
        [string]
        $ReasonFilter,

        [Parameter()]
        [string]
        $RequestedFor,

        [Parameter()]
        [datetime]
        $MaxTime,

        [Parameter()]
        [datetime]
        $MinTime,

        [Parameter()]
        [string]
        $BuildNumber,

        [Parameter()]
        [int[]]
        $Queues,

        [Parameter()]
        [int[]]
        $Definitions,

        [Parameter()]
        [string]
        $RepositoryType
    )

    begin
    {
        If ($PSCmdlet.ParameterSetName -eq 'BySession')
        {
            $currentSession = $Session | Get-APSession
            If ($currentSession)
            {
                $Instance = $currentSession.Instance
                $Collection = $currentSession.Collection
                $Project = $currentSession.Project
                $ApiVersion = (Get-APApiVersion -Version $currentSession.Version)
                $PersonalAccessToken = $currentSession.PersonalAccessToken
            }
        }
    }
    
    process
    {
        $apiEndpoint = Get-APApiEndpoint -ApiType 'build-builds'
        $queryParameters = Set-APQueryParameters -InputObject $PSBoundParameters
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
            Query       = $queryParameters
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'GET'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
        }
        $results = Invoke-APRestMethod @invokeAPRestMethodSplat 
        If ($results.value)
        {
            return $results.value
        }
        else
        {
            return $results
        }
    }
    
    end
    {
    }
}