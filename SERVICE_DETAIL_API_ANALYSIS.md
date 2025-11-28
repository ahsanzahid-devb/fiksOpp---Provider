# Service Detail API Analysis

## Issue: 406 "Record not found" Error

### Problem
When clicking on services from job posts, the `service-detail` API returns **406 "Record not found"** error.

### Root Cause Analysis

#### 1. **Request Format Mismatch**
- **App sends**: JSON format `{"service_id": 23}`
- **Postman (working)**: `form-data` format with `service_id: 27`
- **Backend expects**: `form-data` format (based on Postman test)

#### 2. **Provider Ownership Restriction**
- Services from **other providers** cannot be accessed via `service-detail` API
- Example: Service ID 23 has `provider_id: 18`, but current user is `provider_id: 16`
- Backend validates ownership and returns 406 if provider doesn't match

#### 3. **Service Type Restriction**
- Services with `service_type: "user_post_service"` (from database) may not be accessible
- These services are linked to job posts but may not have full service detail pages
- Backend may restrict access based on service type

### Current Implementation

#### API Call Format (Current - JSON)
```dart
// lib/networks/rest_apis.dart
Future<ServiceDetailResponse> getServiceDetail(Map request) async {
  ServiceDetailResponse res = ServiceDetailResponse.fromJson(
      await handleResponse(await buildHttpResponse('service-detail',
          request: request, method: HttpMethodType.POST)));
  // ...
}
```

**Request sent**: `{"service_id": 23}` (JSON)

#### Postman Format (Working - form-data)
- **Method**: POST
- **URL**: `https://fiksopp.inoor.buzz/api/service-detail`
- **Body Type**: `form-data`
- **Fields**:
  - `service_id`: `27` (Text)

### Solution Implemented

#### 1. Provider Check Before Navigation
```dart
// lib/provider/jobRequest/job_post_detail_screen.dart
).onTap(() async {
  if (data.id != null) {
    // Check if service belongs to a different provider
    if (data.providerId != null && 
        data.providerId.validate() != appStore.userId.validate()) {
      toast(languages.noServiceFound);
      return; // Prevent navigation
    }
    ServiceDetailScreen(serviceId: data.id.validate()).launch(context);
  }
});
```

**Result**: Prevents navigation for services from other providers, shows toast instead of error screen.

#### 2. Error Handling in Service Detail Screen
- Added 406 status code handling in `network_utils.dart`
- Improved error message display
- Shows user-friendly "No Service Found" message

### Backend API Expectations

#### What the Backend Expects:
1. **Request Format**: `form-data` (not JSON)
2. **Field Name**: `service_id` (not `service_id` in JSON)
3. **Provider Validation**: Service must belong to current provider
4. **Service Type**: Regular services (not `user_post_service` type)

#### API Endpoint Details:
- **URL**: `https://fiksopp.inoor.buzz/api/service-detail`
- **Method**: POST
- **Content-Type**: `multipart/form-data` (for form-data) or `application/json` (current)
- **Required Field**: `service_id` (integer)

### Recommendations

#### Option 1: Keep Current Solution (Recommended)
- ✅ Already implemented: Check provider before navigation
- ✅ Shows toast message instead of error screen
- ✅ Better user experience
- ⚠️ Still uses JSON format (may need backend update)

#### Option 2: Change to Form-Data Format
**Pros**:
- Matches Postman format
- May resolve 406 errors for valid services

**Cons**:
- Requires refactoring API call
- May break other parts of app
- Still won't work for services from other providers

**Implementation**:
```dart
Future<ServiceDetailResponse> getServiceDetail(Map request) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('service-detail');
  multiPartRequest.fields.addAll(await getMultipartFields(val: request));
  multiPartRequest.headers.addAll(buildHeaderTokens());
  
  // Use sendMultiPartRequest instead of buildHttpResponse
  // ...
}
```

#### Option 3: Backend Update (Best Long-term)
- Update backend to accept JSON format
- Or allow viewing services from other providers (with permission check)
- Or create separate endpoint for job post services

### Current Status

✅ **Fixed**: Provider check prevents navigation for inaccessible services
✅ **Fixed**: Error handling shows user-friendly messages
⚠️ **Note**: Request format mismatch (JSON vs form-data) may still cause issues for valid services

### Testing

**Test Cases**:
1. ✅ Service from same provider → Should work (if format is accepted)
2. ✅ Service from different provider → Shows toast (prevented)
3. ✅ Service with `user_post_service` type → May need backend update
4. ⚠️ Valid service with JSON format → May return 406 (needs backend confirmation)

### Next Steps

1. **Verify with Backend Team**: 
   - Does backend accept JSON format for `service-detail`?
   - Should services from other providers be accessible?
   - What's the expected behavior for `user_post_service` type?

2. **If Backend Requires Form-Data**:
   - Implement Option 2 (change to form-data format)
   - Test with various service types

3. **If Backend Should Accept JSON**:
   - Request backend update
   - Test after update

---

**Last Updated**: Based on logs showing 406 errors for services from other providers
**Status**: Partial fix implemented (provider check), format issue remains

