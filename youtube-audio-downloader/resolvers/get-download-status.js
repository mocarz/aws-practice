import { util } from '@aws-appsync/utils';
import { get } from '@aws-appsync/utils/dynamodb';

/**
 * Sends a request to get an item with video_id `ctx.args.video_id` from the DynamoDB table.
 * @param {import('@aws-appsync/utils').Context<{video_id: unknown;}>} ctx the context
 * @returns {import('@aws-appsync/utils').DynamoDBGetItemRequest} the request
 */
export function request(ctx) {
    const { video_id } = ctx.args;
    const key = { video_id };
    return get({
        key,
    })
}

/**
 * Returns the fetched DynamoDB item.
 * @param {import('@aws-appsync/utils').Context} ctx the context
 * @returns {*} the DynamoDB item
 */
export function response(ctx) {
    const { error, result } = ctx;
    if (error) {
        return util.appendError(error.message, error.type, result);
    }
    return result;
}
