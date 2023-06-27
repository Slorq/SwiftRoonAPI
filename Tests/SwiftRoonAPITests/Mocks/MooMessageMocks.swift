//
//  MooMessageMocks.swift
//  
//
//  Created by Alejandro Maya on 27/06/23.
//

import Foundation

typealias MooMessageMock = String

extension MooMessageMock {

    static let completeSuccess = "MOO/1 COMPLETE Success\nContent-Type: application/json\nRequest-Id: 0\nContent-Length: 138\n\n{\"core_id\":\"fc519bd4-30c9-4e38-b8ea-53f5816ba75e\",\"display_name\":\"MacBook-Pro\",\"display_version\":\"2.0 (build 1277) production\"}"

    static let continueChanged = "MOO/1 CONTINUE Changed\nContent-Type: application/json\nRequest-Id: 2\nContent-Length: 1286\n\n{\"zones_changed\":[{\"zone_id\":\"16010d60b4bebac50430d2381c9578c87196\",\"display_name\":\"System Output\",\"outputs\":[{\"output_id\":\"17010d60b4bebac50430d2381c9578c87196\",\"zone_id\":\"16010d60b4bebac50430d2381c9578c87196\",\"can_group_with_output_ids\":[\"17010d60b4bebac50430d2381c9578c87196\"],\"display_name\":\"System Output\",\"volume\":{\"type\":\"number\",\"min\":0,\"max\":100,\"value\":100,\"step\":1,\"is_muted\":false,\"hard_limit_min\":0,\"hard_limit_max\":100,\"soft_limit\":100},\"source_controls\":[{\"control_key\":\"1\",\"display_name\":\"System Output\",\"supports_standby\":false,\"status\":\"indeterminate\"}]}],\"state\":\"loading\",\"is_next_allowed\":true,\"is_previous_allowed\":true,\"is_pause_allowed\":true,\"is_play_allowed\":false,\"is_seek_allowed\":false,\"queue_items_remaining\":2,\"queue_time_remaining\":406,\"settings\":{\"loop\":\"disabled\",\"shuffle\":false,\"auto_radio\":true},\"now_playing\":{\"seek_position\":null,\"length\":193,\"one_line\":{\"line1\":\"When Everything Went Wrong - Fantastic Negrito\"},\"two_line\":{\"line1\":\"When Everything Went Wrong\",\"line2\":\"Fantastic Negrito\"},\"three_line\":{\"line1\":\"When Everything Went Wrong\",\"line2\":\"Fantastic Negrito\",\"line3\":\"Arcane League of Legends\"},\"image_key\":\"c167087962b6b7fa4155426c60c96f44\",\"artist_image_keys\":[\"cd7b0a520b5dc10f285197bfe46bfd13\",\"93ee48f9aafce6d06c119430f88fb69f\"]}}]}"

    static let continueRegistered = "MOO/1 CONTINUE Registered\nContent-Type: application/json\nRequest-Id: 1\nContent-Length: 280\n\n{\"core_id\":\"fc519bd4-30c9-4e38-b8ea-53f5816ba75e\",\"display_name\":\"MacBook-Pro\",\"display_version\":\"2.0 (build 1277) production\",\"token\":\"78853ef6-e1f7-4d84-902d-88e0cdd60b05\",\"provided_services\":[\"com.roonlabs.transport:2\"],\"http_port\":9300,\"extension_host\":\"127.0.0.1\"}"

    static let continueSubscribed = "MOO/1 CONTINUE Subscribed\nContent-Type: application/json\nRequest-Id: 2\nContent-Length: 1278\n\n{\"zones\":[{\"zone_id\":\"16010d60b4bebac50430d2381c9578c87196\",\"display_name\":\"System Output\",\"outputs\":[{\"output_id\":\"17010d60b4bebac50430d2381c9578c87196\",\"zone_id\":\"16010d60b4bebac50430d2381c9578c87196\",\"can_group_with_output_ids\":[\"17010d60b4bebac50430d2381c9578c87196\"],\"display_name\":\"System Output\",\"volume\":{\"type\":\"number\",\"min\":0,\"max\":100,\"value\":100,\"step\":1,\"is_muted\":false,\"hard_limit_min\":0,\"hard_limit_max\":100,\"soft_limit\":100},\"source_controls\":[{\"control_key\":\"1\",\"display_name\":\"System Output\",\"supports_standby\":false,\"status\":\"indeterminate\"}]}],\"state\":\"stopped\",\"is_next_allowed\":true,\"is_previous_allowed\":true,\"is_pause_allowed\":false,\"is_play_allowed\":true,\"is_seek_allowed\":false,\"queue_items_remaining\":2,\"queue_time_remaining\":406,\"settings\":{\"loop\":\"disabled\",\"shuffle\":false,\"auto_radio\":true},\"now_playing\":{\"seek_position\":null,\"length\":193,\"one_line\":{\"line1\":\"When Everything Went Wrong - Fantastic Negrito\"},\"two_line\":{\"line1\":\"When Everything Went Wrong\",\"line2\":\"Fantastic Negrito\"},\"three_line\":{\"line1\":\"When Everything Went Wrong\",\"line2\":\"Fantastic Negrito\",\"line3\":\"Arcane League of Legends\"},\"image_key\":\"c167087962b6b7fa4155426c60c96f44\",\"artist_image_keys\":[\"cd7b0a520b5dc10f285197bfe46bfd13\",\"93ee48f9aafce6d06c119430f88fb69f\"]}}]}"

    static let request = "MOO/1 REQUEST com.roonlabs.ping:1/ping\nLogging: quiet\nRequest-Id: 1\n\n"

    static let invalidFirstLine = "MOO1 invalid first line"

    static let invalidFirstLineEnding = "MOO/1 REQUEST invalidending"

    static let invalidVerb = "MOO/1 INVALIDVERB invalid first line"

    static let invalidHeadersDelimiting = "MOO/1 REQUEST com.roonlabs.ping:1/ping\nLogging: quiet\nRequest-Id: 1"

    static let invalidHeaderLine = "MOO/1 REQUEST com.roonlabs.ping:1/ping\ninvalidHeaderLine\n\n"

    static let invalidHeaderName = "MOO/1 REQUEST com.roonlabs.ping:1/ping\nUnknown-Header: quiet\n\n"

    static let missingRequestID = "MOO/1 REQUEST com.roonlabs.ping:1/ping\nLogging: quiet\n\n"
}
