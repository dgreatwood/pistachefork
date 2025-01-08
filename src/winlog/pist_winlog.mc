;// SPDX-FileCopyrightText: 2024 Duncan Greatwood
;// SPDX-License-Identifier: Apache-2.0

MessageIdTypedef=DWORD

;// Provider Information
;// Name: Pistache-Provider
;// GUID: {cb8de796-f9ba-4712-a13f-99bdf30e06aa}
;// Symbol: PISTACHE_GUID
;// Resource File: %ProgramFiles%\pistache_distribution\bin\pistachelog.dll
;// Message File: %ProgramFiles%\pistache_distribution\bin\pistachelog.dll

;// Channels
;// cadminbltin: Application (imported)
;// cadmin: Pistache-BaseProvider/Admin (Admin)
;// coperl: Pistache-BaseProvider/Operational (Operational)
;// canalc: Pistache-BaseProvider/Analytic (Analytic)
;// cdebug: Pistache-BaseProvider/Debug (Debug)

;// Tasks
;// TASK_PSTCH: PSTCH (value=1)

;// Templates
;// t2: Msg (win:UnicodeString)
;// t3: File (win:UnicodeString), Line (win:Int32), Function (win:UnicodeString), Msg (win:UnicodeString)

;// Events
MessageId=1
SymbolicName=PSTCH_DEBUG_NL
Language=English
DEBUG %1
.
;// Channel: cdebug
;// Level: win:Verbose
;// Task: PSTCH
;// Template: t2

MessageId=2
SymbolicName=PSTCH_INFO_NL
Language=English
INFO %1
.
;// Channel: canalc
;// Level: win:Informational
;// Task: PSTCH
;// Template: t2

MessageId=3
SymbolicName=PSTCH_NOTICE_NL
Language=English
NOTICE %1
.
;// Channel: canalc
;// Level: win:Informational
;// Task: PSTCH
;// Template: t2

MessageId=4
SymbolicName=PSTCH_WARNING_NL
Language=English
WARNING %1
.
;// Channel: coperl
;// Level: win:Warning
;// Task: PSTCH
;// Template: t2

MessageId=5
SymbolicName=PSTCH_ERR_NL
Language=English
ERR %1
.
;// Channel: coperl
;// Level: win:Error
;// Task: PSTCH
;// Template: t2

MessageId=6
SymbolicName=PSTCH_CRIT_NL
Language=English
CRIT %1
.
;// Channel: cadmin
;// Level: win:Critical
;// Task: PSTCH
;// Template: t2

MessageId=7
SymbolicName=PSTCH_ALERT_NL
Language=English
ALERT %1
.
;// Channel: cadmin
;// Level: win:Critical
;// Task: PSTCH
;// Template: t2

MessageId=8
SymbolicName=PSTCH_EMERG_NL
Language=English
EMERG %1
.
;// Channel: cadmin
;// Level: win:Critical
;// Task: PSTCH
;// Template: t2

MessageId=102
SymbolicName=PSTCH_CBLTIN_INFO_NL
Language=English
INFO %1
.
;// Channel: cadminbltin
;// Level: win:Informational
;// Task: PSTCH
;// Template: t2

MessageId=103
SymbolicName=PSTCH_CBLTIN_NOTICE_NL
Language=English
NOTICE %1
.
;// Channel: cadminbltin
;// Level: win:Informational
;// Task: PSTCH
;// Template: t2

MessageId=104
SymbolicName=PSTCH_CBLTIN_WARNING_NL
Language=English
WARNING %1
.
;// Channel: cadminbltin
;// Level: win:Warning
;// Task: PSTCH
;// Template: t2

MessageId=105
SymbolicName=PSTCH_CBLTIN_ERR_NL
Language=English
ERR %1
.
;// Channel: cadminbltin
;// Level: win:Error
;// Task: PSTCH
;// Template: t2

MessageId=106
SymbolicName=PSTCH_CBLTIN_CRIT_NL
Language=English
CRIT %1
.
;// Channel: cadminbltin
;// Level: win:Critical
;// Task: PSTCH
;// Template: t2

MessageId=107
SymbolicName=PSTCH_CBLTIN_ALERT_NL
Language=English
ALERT %1
.
;// Channel: cadminbltin
;// Level: win:Critical
;// Task: PSTCH
;// Template: t2

MessageId=108
SymbolicName=PSTCH_CBLTIN_EMERG_NL
Language=English
EMERG %1
.
;// Channel: cadminbltin
;// Level: win:Critical
;// Task: PSTCH
;// Template: t2

; // Event Declarations
MessageId=1001
SymbolicName=PSTCH_DEBUG_NL_EVENT
Language=English
DEBUG %1
.

MessageId=1002
SymbolicName=PSTCH_INFO_NL_EVENT
Language=English
INFO %1
.

MessageId=1003
SymbolicName=PSTCH_NOTICE_NL_EVENT
Language=English
NOTICE %1
.

MessageId=1004
SymbolicName=PSTCH_WARNING_NL_EVENT
Language=English
WARNING %1
.

MessageId=1005
SymbolicName=PSTCH_ERR_NL_EVENT
Language=English
ERR %1
.

MessageId=1006
SymbolicName=PSTCH_CRIT_NL_EVENT
Language=English
CRIT %1
.

MessageId=1007
SymbolicName=PSTCH_ALERT_NL_EVENT
Language=English
ALERT %1
.

MessageId=1008
SymbolicName=PSTCH_EMERG_NL_EVENT
Language=English
EMERG %1
.

MessageId=1102
SymbolicName=PSTCH_CBLTIN_INFO_NL_EVENT
Language=English
INFO %1
.

MessageId=1103
SymbolicName=PSTCH_CBLTIN_NOTICE_NL_EVENT
Language=English
NOTICE %1
.

MessageId=1104
SymbolicName=PSTCH_CBLTIN_WARNING_NL_EVENT
Language=English
WARNING %1
.

MessageId=1105
SymbolicName=PSTCH_CBLTIN_ERR_NL_EVENT
Language=English
ERR %1
.

MessageId=1106
SymbolicName=PSTCH_CBLTIN_CRIT_NL_EVENT
Language=English
CRIT %1
.

MessageId=1107
SymbolicName=PSTCH_CBLTIN_ALERT_NL_EVENT
Language=English
ALERT %1
.

MessageId=1108
SymbolicName=PSTCH_CBLTIN_EMERG_NL_EVENT
Language=English
EMERG %1
.

; // Function Declarations
; // Provider Registration and Unregistration
; // EventWritePSTCH_*: Writes events to the ETW log.

; #pragma once

; #include <windows.h>
; #include <wmistr.h>
; #include <evntrace.h>
;
; // Provider handle
; static REGHANDLE PistacheProviderHandle = 0;
; 
; // Define the GUID for the provider
; // {cb8de796-f9ba-4712-a13f-99bdf30e06aa}
; static const GUID PISTACHE_GUID =
; { 0xcb8de796, 0xf9ba, 0x4712, { 0xa1, 0x3f, 0x99, 0xbd, 0xf3, 0x0e, 0x06, 0xaa } };
; 
; // Event descriptors for each event type
; static const EVENT_DESCRIPTOR EventDesc_Debug = {1001, 1, 0, 5, 0, 0, 0};     // Debug level
; static const EVENT_DESCRIPTOR EventDesc_Info = {1002, 1, 0, 4, 0, 0, 0};      // Info level
; static const EVENT_DESCRIPTOR EventDesc_Notice = {1003, 1, 0, 4, 0, 0, 0};    // Notice level
; static const EVENT_DESCRIPTOR EventDesc_Warning = {1004, 1, 0, 3, 0, 0, 0};   // Warning level
; static const EVENT_DESCRIPTOR EventDesc_Error = {1005, 1, 0, 2, 0, 0, 0};     // Error level
; static const EVENT_DESCRIPTOR EventDesc_Critical = {1006, 1, 0, 1, 0, 0, 0};  // Critical level
; static const EVENT_DESCRIPTOR EventDesc_Alert = {1007, 1, 0, 1, 0, 0, 0};     // Alert level
; static const EVENT_DESCRIPTOR EventDesc_Emergency = {1008, 1, 0, 1, 0, 0, 0}; // Emergency level
; 
; // Built-in channel event descriptors
; static const EVENT_DESCRIPTOR EventDesc_CBltin_Info = {1102, 1, 0, 4, 0, 0, 0};      // Info level
; static const EVENT_DESCRIPTOR EventDesc_CBltin_Notice = {1103, 1, 0, 4, 0, 0, 0};    // Notice level
; static const EVENT_DESCRIPTOR EventDesc_CBltin_Warning = {1104, 1, 0, 3, 0, 0, 0};   // Warning level
; static const EVENT_DESCRIPTOR EventDesc_CBltin_Error = {1105, 1, 0, 2, 0, 0, 0};     // Error level
; static const EVENT_DESCRIPTOR EventDesc_CBltin_Critical = {1106, 1, 0, 1, 0, 0, 0};  // Critical level
; static const EVENT_DESCRIPTOR EventDesc_CBltin_Alert = {1107, 1, 0, 1, 0, 0, 0};     // Alert level
; static const EVENT_DESCRIPTOR EventDesc_CBltin_Emergency = {1108, 1, 0, 1, 0, 0, 0}; // Emergency level
; 
; // Provider Registration
; static inline ULONG EventRegisterPistache_Provider() {
;     return EventRegister(&PISTACHE_GUID, nullptr, nullptr, &PistacheProviderHandle);
; }
; 
; static inline ULONG EventUnregisterPistache_Provider() {
;     return EventUnregister(PistacheProviderHandle);
; }
; 
; // Macro to generate event writing functions
; #define GENERATE_EVENT_WRITE_FUNCTION(event_name, event_descriptor) \
;     static inline ULONG event_name(PCWSTR message) { \
;         EVENT_DATA_DESCRIPTOR descriptor; \
;         EventDataDescCreate(&descriptor, message, (ULONG)((wcslen(message) + 1) * sizeof(WCHAR))); \
;         return EventWrite(PistacheProviderHandle, &event_descriptor, 1, &descriptor); \
;     }
; 
; // Generate event writing functions for each event type
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_DEBUG_NL, EventDesc_Debug)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_INFO_NL, EventDesc_Info)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_NOTICE_NL, EventDesc_Notice)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_WARNING_NL, EventDesc_Warning)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_ERR_NL, EventDesc_Error)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_CRIT_NL, EventDesc_Critical)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_ALERT_NL, EventDesc_Alert)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_EMERG_NL, EventDesc_Emergency)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_CBLTIN_INFO_NL, EventDesc_CBltin_Info)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_CBLTIN_NOTICE_NL, EventDesc_CBltin_Notice)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_CBLTIN_WARNING_NL, EventDesc_CBltin_Warning)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_CBLTIN_ERR_NL, EventDesc_CBltin_Error)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_CBLTIN_CRIT_NL, EventDesc_CBltin_Critical)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_CBLTIN_ALERT_NL, EventDesc_CBltin_Alert)
; GENERATE_EVENT_WRITE_FUNCTION(EventWritePSTCH_CBLTIN_EMERG_NL, EventDesc_CBltin_Emergency)
; 
; // Macro to generate AssumeEnabled variants
; #define GENERATE_ASSUME_ENABLED_MACRO(event_name) \
;     static inline ULONG event_name##_AssumeEnabled(PCWSTR message) { \
;         return event_name(message); \
;     }
; 
; // Generate AssumeEnabled macros for each event type
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_DEBUG_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_INFO_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_NOTICE_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_WARNING_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_ERR_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_CRIT_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_ALERT_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_EMERG_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_CBLTIN_INFO_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_CBLTIN_NOTICE_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_CBLTIN_WARNING_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_CBLTIN_ERR_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_CBLTIN_CRIT_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_CBLTIN_ALERT_NL)
; GENERATE_ASSUME_ENABLED_MACRO(EventWritePSTCH_CBLTIN_EMERG_NL)

